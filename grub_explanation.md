# GRUB and Kernel Build Notes

## README.md Lines 185-191 (Summary)

- Line 185: Building the kernel (`sudo make`) can take a long time (around 3 hours). It's a heads-up so you don't think the build is stuck.
- Line 187: During `sudo make install`, the boot partition can be full. If that happens, remove old kernels to free space, then retry.
- Line 189: After installing, reboot. If you hit a GRUB "out of memory" error, the README provides a recovery procedure.
- Line 191: Start the recovery by booting into recovery mode or a live USB Ubuntu session so you can edit system files.

## README.md Lines 192-200 (Why Those Steps Work)

- `mount -o remount,rw /`: Recovery mode usually mounts `/` read-only. This remounts it read-write so edits can be made.
- `sudo nano /etc/initramfs-tools/initramfs.conf`: Opens initramfs config.
- Change `MODULES=most` to `MODULES=dep`: This reduces the size of the initramfs by only including required modules, which helps avoid GRUB memory errors.
- `sudo update-initramfs -c -k 5.15.195-rt90`: Regenerates a new initramfs for that kernel version.
- `sudo update-grub`: Rebuilds the GRUB menu to point at the updated initramfs.

## Script Provided

- `fix_grub_out_of_memory.sh`
- Usage:

```bash
sudo bash fix_grub_out_of_memory.sh 5.15.195-rt90
```

If you omit the version, it defaults to `5.15.195-rt90`.

## What "GRUB Memory" Means

GRUB runs before Linux, in a very limited pre-boot environment. "Out of memory" means GRUB couldn't allocate enough pre-boot RAM to load what it needs (often a large initramfs). It is not about disk space.

## How GRUB Can Run Out of Memory

- A large initramfs (for example when `MODULES=most` includes many drivers).
- Extra GRUB modules, themes, or large fonts.
- Firmware limits that restrict available pre-boot memory.

## Where GRUB Is Installed

This depends on boot mode:

UEFI systems:
- GRUB files live on the EFI System Partition (ESP), a small FAT32 partition.
- Typical mount point is `/boot/efi`.
- Files are under `EFI/ubuntu/` (or a similar vendor folder).

Legacy BIOS systems:
- GRUB's first stage is in the MBR (first 512 bytes of the disk).
- The rest of GRUB is stored under `/boot/grub` on the Linux root partition, or in the post-MBR gap if available.

## Dual-Boot: Keep Ubuntu 25 as Primary GRUB

Goal:
- Firmware boots Ubuntu 25's GRUB by default.
- Ubuntu 20 stays bootable and does not overwrite the shared EFI entry.

Steps:
1. From Ubuntu 25:
```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ubuntu25
sudo update-grub
```

2. From Ubuntu 20:
```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ubuntu20
sudo update-grub
```

3. Back in Ubuntu 25, set boot order (replace `0003` with the Ubuntu 25 entry):
```bash
sudo efibootmgr -v
sudo efibootmgr -o 0003,0001,0002
```

Operational notes:
- Run `grub-install` only in Ubuntu 25 to keep it primary.
- `update-grub` is safe in either OS; it only updates that OS's `/boot/grub/grub.cfg`.

## Helper Script

Use `set_ubuntu25_primary_grub.sh` from Ubuntu 25 to create a dedicated EFI entry and make it default.
