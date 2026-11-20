#!/bin/bash
# Rebuilds whenever the device tree's main branch gets a new commit, and puts
# each run's result in the bucket, so the fixes can be found without SSH:
#   gs://BUCKET/loop/status.txt     state, commit, times
#   gs://BUCKET/loop/errors.txt     the error lines of the last run
#   gs://BUCKET/loop/build-all.log  the whole last run
# On success the images go to gs://BUCKET/results-DATE (cloud-build.sh) and
# this VM deletes itself. With no new commit for IDLE_LIMIT seconds (2 hours)
# it powers off; a stopped VM bills only its disk.
# Start:  tmux new -d -s loop 'BUCKET=gs://YOUR-BUCKET bash ~/build-loop.sh'
# Starts again after every boot if added to cron (see the end of this file).
: "${BUCKET:?set BUCKET=gs://...}"
# cron starts with a bare PATH; gcloud is in /snap/bin on Google's Ubuntu images.
export PATH="$HOME/bin:/snap/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
IDLE_LIMIT=${IDLE_LIMIT:-7200}
REPO=https://github.com/Bubbagum88/lineage_device_oculus_monterey
LAST=$(cat ~/.loop-last 2>/dev/null)
IDLE=0

status() {
  printf '%s\n' "$@" "updated=$(date -u +%FT%TZ)" > ~/loop-status.txt
  gcloud storage cp ~/loop-status.txt "$BUCKET/loop/status.txt" --quiet
}

while true; do
  HEAD=$(git ls-remote "$REPO" refs/heads/main | cut -f1)
  if [ -z "$HEAD" ] || [ "$HEAD" = "$LAST" ]; then
    sleep 60
    IDLE=$((IDLE + 60))
    if [ "$IDLE" -ge "$IDLE_LIMIT" ]; then
      status "state=idle-poweroff" "commit=$LAST"
      sudo poweroff
      exit 0
    fi
    continue
  fi

  status "state=building" "commit=$HEAD" "started=$(date -u +%FT%TZ)"
  # The build script lives in the device tree (tools/gcp), so a change to it
  # arrives with the commit; keep the local copy if the download fails.
  curl -fsSL "https://raw.githubusercontent.com/Bubbagum88/lineage_device_oculus_monterey/$HEAD/tools/gcp/cloud-build.sh" \
    -o ~/cloud-build.sh.new && mv ~/cloud-build.sh.new ~/cloud-build.sh
  if [ -n "$LAST" ]; then SKIP=1; else SKIP=; fi
  SKIP_SYNC=$SKIP bash ~/cloud-build.sh > ~/build-all.log 2>&1
  LAST=$HEAD
  echo "$HEAD" > ~/.loop-last
  IDLE=0

  grep -n -B3 -A8 "FAILED:\|error:\|ninja: build stopped\|ckati failed" ~/build-all.log \
    | tail -120 > ~/loop-errors.txt
  gcloud storage cp ~/build-all.log ~/loop-errors.txt "$BUCKET/loop/" --quiet

  if [ -f ~/results/system.img ]; then
    status "state=success" "commit=$HEAD" "images=$(grep -o 'gs://[^ ]*results-[0-9-]*' ~/build-all.log | tail -1)"
    NAME=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/name)
    ZONE=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/zone | sed 's#.*/##')
    gcloud compute instances delete "$NAME" --zone="$ZONE" --delete-disks=all --quiet || sudo poweroff
    exit 0
  fi
  status "state=failed" "commit=$HEAD" "finished=$(date -u +%FT%TZ)"
done

# To start the loop after every boot, run once:
#   (crontab -l 2>/dev/null; echo "@reboot BUCKET=gs://YOUR-BUCKET tmux new -d -s loop 'bash ~/build-loop.sh'") | crontab -
