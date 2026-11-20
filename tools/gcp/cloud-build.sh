#!/bin/bash
# LineageOS 17.1 build for the Quest 1 on a Google Cloud VM (Ubuntu 22.04).
# Run inside tmux:  tmux new -s build 'bash ~/cloud-build.sh 2>&1 | tee ~/build-all.log'
# Re-run it after any failure: every step skips what is already done.
#   BUCKET  your Cloud Storage bucket holding payload.bin (gs://NAME)
set -e
BUCKET="${BUCKET:?set BUCKET=gs://your-bucket-name first}"
SRC=~/lineage-17.1
STOCK=~/stock

echo "== 1/6 packages"
if [ ! -f ~/.pkgs-done ]; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y bc bison build-essential ccache curl flex \
    g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev \
    liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop \
    pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python2 python3 unzip tmux
  # Android 10's build calls `python` and expects Python 2.
  sudo ln -sf /usr/bin/python2 /usr/local/bin/python
  mkdir -p ~/bin
  curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
  chmod a+x ~/bin/repo
  git config --global user.name >/dev/null || git config --global user.name builder
  git config --global user.email >/dev/null || git config --global user.email builder@localhost
  touch ~/.pkgs-done
fi
export PATH="$HOME/bin:$PATH" USE_CCACHE=1 CCACHE_EXEC=/usr/bin/ccache
ccache -M 20G >/dev/null

echo "== 2/6 stock system.img from payload.bin"
mkdir -p "$STOCK"
if [ ! -f "$STOCK/system.img" ]; then
  gcloud storage cp "$BUCKET/payload.bin" "$STOCK/payload.bin"
  python3 ~/payload_extract.py "$STOCK/payload.bin" system "$STOCK/system.img"
fi

echo "== 3/6 LineageOS 17.1 source (the long download)"
mkdir -p "$SRC" && cd "$SRC"
[ -d .repo ] || repo init -u https://github.com/LineageOS/android.git -b lineage-17.1 --depth=1
# build-loop.sh sets SKIP_SYNC=1 after its first run: only the device tree changes between runs.
if [ -z "$SKIP_SYNC" ] || [ ! -f build/envsetup.sh ]; then
  repo sync -c -j"$(nproc)" --no-tags --no-clone-bundle --force-sync
fi
# Some projects keep binaries in Git LFS (the WebView APKs, for one). Without
# this, the build copies a 134-byte LFS pointer instead of the APK.
git lfs install >/dev/null
repo forall -j"$(nproc)" -c 'if grep -qs "filter=lfs" .gitattributes; then git lfs pull; fi'

echo "== 4/6 Quest 1 device tree"
if [ -d device/oculus/monterey ]; then
  git -C device/oculus/monterey pull --ff-only
else
  git clone -b main https://github.com/Bubbagum88/lineage_device_oculus_monterey device/oculus/monterey
fi

# Kernel source (BoardConfig builds the kernel from it, and LineageOS makes the
# kernel headers from it): Meta's released Quest 1 kernel, 4.4.205.
if [ ! -f kernel/oculus/monterey/Makefile ]; then
  git clone --depth 1 -b oculus-quest-kernel-master \
    https://github.com/facebookincubator/oculus-linux-kernel kernel/oculus/monterey
fi

echo "== 5/6 Meta's blobs from the stock image"
sudo mkdir -p /mnt/q1stock
mountpoint -q /mnt/q1stock || sudo mount -o ro,loop "$STOCK/system.img" /mnt/q1stock
(cd device/oculus/monterey && ./extract-files.sh /mnt/q1stock)
sudo umount /mnt/q1stock

echo "== 6/6 build"
set +e
source build/envsetup.sh
lunch lineage_monterey-userdebug || exit 1
set -o pipefail
m bacon -j"$(nproc)" 2>&1 | tee ~/build.log
RC=$?
OUT=out/target/product/monterey
rm -rf ~/results
mkdir -p ~/results
cp ~/build.log ~/results/
if [ $RC -eq 0 ]; then
  cp $OUT/lineage-17.1-*.zip $OUT/boot.img $OUT/system.img ~/results/ 2>/dev/null
fi
gcloud storage cp -r ~/results "$BUCKET/results-$(date +%Y%m%d-%H%M)"
echo "Build exit code $RC. Results copied to $BUCKET."
