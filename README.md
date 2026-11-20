# LineageOS 20.0 device tree for the Oculus Quest (monterey)

**Status: has never booted. Untested. Experimental.** Forked from literallycat's
auto-generated tree; this branch fixes the build problems found by reading it.
Nothing here gives VR: head/controller tracking and Meta's compositor are not
part of LineageOS. The best a first boot can give is flat 2D Android.

## Target

LineageOS 20.0 (Android 13). The stock Quest firmware is Android 10
(`vr_monterey-user 10 QQ3A.200805.001 49845030443200410`), so Meta's vendor
blobs were built for an older Android than this branch: some may need shims
(`blob_fixup` in extract-files.sh). Branch `lineage-17.1` matches stock and is
the first one to try. Kernel: Meta's stock prebuilt 4.4.205
(`prebuilts/kernel`, Image.gz with appended dtb).

## Device facts used

- Legacy system-as-root, A/B, recovery-as-boot (same layout as the Pixel 2).
- No vendor partition: `/vendor` lives in `/system` (`TARGET_COPY_OUT_VENDOR := system/vendor`).
- Partition sizes: boot 67108864, system 2684354560 bytes (`blockdev
  --getsize64` on a Quest 1; same as the openquest project measured).

## Build

```
repo init -u https://github.com/LineageOS/android.git -b lineage-20.0
repo sync
# put this tree at device/oculus/monterey
cd device/oculus/monterey && ./extract-files.sh /path/to/stock/system/dump
cd ../../.. && source build/envsetup.sh && lunch lineage_monterey-userdebug && m bacon
```

Build `userdebug`: SELinux is permissive on the kernel command line for
bring-up (no sepolicy yet), which only userdebug/eng builds honour.

## Safety

- Test with `fastboot boot` (RAM only) before ever flashing anything.
- Back up boot_a/b and system_a/b first.
- **Never run `fastboot oem lock`.** It can brick the headset.
- After a failed boot: `fastboot getvar slot-unbootable:a`, then `fastboot set_active a`.

## Known gaps

No sepolicy, no overlays, no audio/Wi-Fi/display configs beyond the blobs, no
tracking, no VR compositor.

## Android 13 kernel blocker (likely)

Meta's prebuilt 4.4.205 kernel has `CONFIG_BPF_SYSCALL` and `CONFIG_BPF_JIT`
off (read from its embedded config, `IKCONFIG`). Android 13's networking stack
uses eBPF, so expect netd/bpfloader to fail on this kernel. A kernel rebuilt
from Meta's source (facebookincubator/oculus-linux-kernel) with BPF enabled, and
the eBPF backports other 4.4 LineageOS 20 devices carry, is probably needed.
