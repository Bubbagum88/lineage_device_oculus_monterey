# LineageOS for the Oculus Quest 1 (monterey)

An attempt to run LineageOS on the original Oculus Quest (2019, codename
`monterey`, Snapdragon 835 / msm8998). This repository is the Android device
tree: the build configuration that tells LineageOS how to build for this
headset.

> **Status: experimental. It has never booted.** No build from this tree has
> been tested on a headset yet. Even once it boots, it will be flat 2D Android:
> head tracking, controller tracking and Meta's VR compositor are not part of
> LineageOS. See [What works](#what-works) below.

## Branches

| Branch | LineageOS | Android | Notes |
|---|---|---|---|
| `main` | 17.1 | 10 | Same as `lineage-17.1`. Start here. |
| `lineage-17.1` | 17.1 | 10 | Matches the stock firmware's Android version, so Meta's blobs run unchanged. |
| `lineage-18.1` | 18.1 | 11 | Blobs are Android 10 (VNDK 29): some may need shims. |
| `lineage-20` | 20.0 | 13 | Needs the above, plus most likely a kernel with BPF enabled (Meta's has `CONFIG_BPF_SYSCALL` off). |

LineageOS 20 is the highest version this headset can reach without changing
how it boots: Android 14 dropped support for legacy system-as-root.

## What works

| Part | State |
|---|---|
| Build configuration | Fixed for each branch by reading LineageOS's build system; **no full build yet** |
| Boot | Never tested |
| Display, Wi-Fi, audio, Bluetooth | Blobs listed in `proprietary-files.txt`; untested |
| SELinux | No policy yet; permissive for bring-up (userdebug builds only) |
| Head / controller tracking, VR compositor | **Not provided.** These live in Meta's system apps and services, not in LineageOS |

## Device facts

Measured on a Quest 1 running firmware `49845030443200410` (Android 10):

- A/B slots, legacy system-as-root, recovery-as-boot (same boot layout as the Pixel 2).
- No vendor partition: `/vendor` lives inside `/system`.
- Treble: `ro.treble.enabled=true`, `ro.vndk.version=29`.
- Partition sizes: `boot_a` 67108864 bytes, `system_a` 2684354560 bytes.
- Kernel: Meta's prebuilt Linux 4.4.205 (`prebuilts/kernel`, Image.gz with appended dtb).

## Building (lineage-17.1)

Needs a Linux PC (or WSL2) with about 300 GB free, 16 GB+ RAM, and an
Ubuntu 18.04/20.04-era toolchain. A first build takes several hours.

```
repo init -u https://github.com/LineageOS/android.git -b lineage-17.1
repo sync
git clone -b lineage-17.1 https://github.com/Bubbagum88/lineage_device_oculus_monterey device/oculus/monterey
cd device/oculus/monterey && ./extract-files.sh /path/to/stock/system/dump && cd ../../..
source build/envsetup.sh
lunch lineage_monterey-userdebug
m bacon
```

`extract-files.sh` copies Meta's vendor blobs from a dump of the stock system
(or from a connected headset over adb) into `vendor/oculus/monterey`. Those
blobs are Meta's and are never committed here.

## Safety

The Quest 1 is easy to brick. Read this before testing anything.

- **Never run `fastboot oem lock`.** It relocks the bootloader and can leave the
  headset unbootable with no way back.
- Back up `boot_a`, `boot_b`, `system_a`, `system_b` and `persist` before writing anything.
- `fastboot boot` runs a boot image from RAM without writing it, but because
  of legacy system-as-root the kernel still mounts the system partition, so it
  cannot test a new system on its own. Testing LineageOS means writing its system
  image to the **inactive** slot and switching with `fastboot set_active`.
- After a failed boot: `fastboot getvar slot-unbootable:a`, then
  `fastboot set_active a` to get back to the stock slot.
- There is no UART access on a stock headset, so early boot failures leave no log.

## Credits

- **literallycat**: the original auto-generated device tree this is forked from.
- **openquest** (github.com/DIYTechnologist/openquest): published Quest 1
  research (partition sizes, legacy system-as-root) that this tree's fixes were
  checked against. No openquest code is included.
- **Meta**: the kernel source is published at
  github.com/facebookincubator/oculus-linux-kernel.
- The LineageOS Project.

Device tree files are Apache-2.0 (see the SPDX headers).
