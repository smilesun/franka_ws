# What To Do In make menuconfig

Follow these steps inside the `menuconfig` text UI:

1. Go to `General setup`.
2. Select `Preemption Model`.
3. Choose `Fully Preemptible Kernel (Real-Time)`.
4. Go back to the top menu.
5. Go to `File systems`.
6. Go to `Network File Systems`.
7. Highlight `NFS server support`.
8. Press `N` to disable it (it should change from `M` to `[ ]`).
9. Press `Esc` twice, choose `Save`.
10. When prompted for a filename, press `Enter` to accept the default `.config`.
11. Exit `menuconfig`.

# Config Restart Prompts During Build

If the build restarts config and asks about signing keys, you can accept defaults with these tips:

1. `MODULE_SIG_KEY`: press `Enter` to keep `certs/signing_key.pem`.
2. `MODULE_SIG_KEY_TYPE`: choose `1` (RSA) or press `Enter` if it defaults to RSA.
3. `SYSTEM_TRUSTED_KEYRING`: enter `Y`.
4. `SYSTEM_TRUSTED_KEYS`: leave empty and press `Enter`.
5. `SYSTEM_REVOCATION_KEYS` (if prompted): leave empty and press `Enter`.

# Resuming After Missing Dependencies

If the build fails due to a missing package (like `libelf-dev`), install it and resume the build without starting over:

1. `cd ~/kernel/linux-5.15.195`
2. `make -j"$(nproc)"`
