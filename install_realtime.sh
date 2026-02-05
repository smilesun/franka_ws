#!/usr/bin/env bash
set -euo pipefail

# This script guides you through the RT kernel setup.
# It automates what it can and pauses for required manual steps.

mkdir -p "${HOME}/kernel"
cd "${HOME}/kernel"

KERNEL_VERSION="5.15.195"
RT_PATCH="patch-5.15.195-rt90"
KERNEL_TAR="linux-${KERNEL_VERSION}.tar.gz"
KERNEL_DIR="linux-${KERNEL_VERSION}"
BASE_CONFIG="/boot/config-$(uname -r)"
RT_SUFFIX="${RT_PATCH#patch-}"
RT_SUFFIX="${RT_SUFFIX#${KERNEL_VERSION}-}"

if [[ "${1:-}" == "--check" ]]; then
  pass=true
  echo "Post-reboot RT kernel check"
  echo "Expected kernel version format:"
  echo "  ${KERNEL_VERSION}-${RT_SUFFIX}"
  echo
  echo "uname -r:"
  current_kernel="$(uname -r)"
  echo "${current_kernel}"
  if [[ "${current_kernel}" != *"${KERNEL_VERSION}-${RT_SUFFIX}"* ]]; then
    pass=false
  fi
  echo
  echo "/boot/config-$(uname -r) (filtered):"
  if [[ -r "/boot/config-${current_kernel}" ]]; then
    preempt_lines="$(grep -E "CONFIG_PREEMPT_RT|CONFIG_PREEMPT" "/boot/config-${current_kernel}" || true)"
    echo "${preempt_lines}"
    if [[ "${preempt_lines}" != *"CONFIG_PREEMPT_RT=y"* ]]; then
      pass=false
    fi
  else
    echo "(not readable or not present)"
    pass=false
  fi
  echo
  if [[ -r /sys/kernel/realtime ]]; then
    echo "/sys/kernel/realtime:"
    realtime_flag="$(cat /sys/kernel/realtime)"
    echo "${realtime_flag}"
    if [[ "${realtime_flag}" != "1" ]]; then
      pass=false
    fi
  else
    echo "/sys/kernel/realtime: (not readable or not present)"
    pass=false
  fi
  echo
  if [[ "${pass}" == true ]]; then
    echo "RT kernel check: PASS"
  else
    echo "RT kernel check: FAIL"
  fi
  exit 0
fi

wget "https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/${KERNEL_TAR}"
wget "https://www.kernel.org/pub/linux/kernel/projects/rt/5.15/older/${RT_PATCH}.patch.xz"

tar -xzf "${KERNEL_TAR}"
xz -d "${RT_PATCH}.patch.xz"

cd "${KERNEL_DIR}/"
patch -p1 <"../${RT_PATCH}.patch"
if [[ -f "${BASE_CONFIG}" ]]; then
  cp "${BASE_CONFIG}" .config
else
  echo "Warning: ${BASE_CONFIG} not found. You may need to supply a base .config manually."
fi

echo
echo "Manual step: make menuconfig"
echo "In menuconfig:"
echo "- Set PREEMPT_RT (Fully Preemptible Kernel (Real-Time))"
echo "- Disable NFS server support (if enabled)"
read -r -p "Press Enter to run 'make menuconfig'..."
make menuconfig

echo
echo "Manual step: disable trusted/revocation keys in .config"
echo "This avoids build failures on some systems."
read -r -p "Press Enter to apply scripts/config changes..."
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS

sudo apt install -y dwarves
sudo apt install -y zstd

echo
echo "Build step: this can take a long time."
read -r -p "Press Enter to build the kernel (make -j\"$(nproc)\")..."
make -j"$(nproc)"

echo
read -r -p "Press Enter to install modules (sudo make modules_install)..."
sudo make modules_install

echo
read -r -p "Press Enter to install the kernel (sudo make install)..."
sudo make install

echo
echo "Updating initramfs and grub..."
sudo update-initramfs -c -k "${KERNEL_VERSION}-${RT_SUFFIX}"
sudo update-grub

echo
echo "Done. Reboot and select the new RT kernel if needed."
echo "After reboot, verify with:"
echo "  uname -r"
echo "  cat /sys/kernel/realtime"
echo "Expected kernel version format:"
echo "  ${KERNEL_VERSION}-${RT_SUFFIX}"
