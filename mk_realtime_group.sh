#!/usr/bin/env bash
# Fix "libfranka: unable to set realtime scheduling: Operation not permitted"
# by:
#  1) creating the realtime group (if needed) and adding the current user
#  2) installing PAM limits so /etc/security/limits.d/* is actually applied
#  3) writing RT + memlock limits for the realtime group
#  4) printing verification commands to run after you log out/in

set -euo pipefail

# ---- Config (change if you want) ----
RT_GROUP="realtime"
LIMITS_FILE="/etc/security/limits.d/99-realtime.conf"

# Detect the "real" user when running via sudo
REAL_USER="${SUDO_USER:-$USER}"

echo "=== Franka/libfranka realtime permissions setup ==="
echo "User to configure: ${REAL_USER}"
echo "RT group: ${RT_GROUP}"
echo

# ---- 1) Create realtime group (no error if it already exists) ----
echo "[1/4] Ensuring group '${RT_GROUP}' exists..."
if getent group "${RT_GROUP}" >/dev/null; then
  echo "  - Group '${RT_GROUP}' already exists."
else
  sudo groupadd "${RT_GROUP}"
  echo "  - Created group '${RT_GROUP}'."
fi

# ---- 2) Add user to realtime group ----
echo "[2/4] Adding user '${REAL_USER}' to '${RT_GROUP}' group..."
sudo usermod -aG "${RT_GROUP}" "${REAL_USER}"
echo "  - Added. (This takes effect after logout/login.)"
echo

# ---- 3) Ensure PAM loads pam_limits.so (your grep output was empty) ----
# Without pam_limits.so, /etc/security/limits.d/*.conf won't apply,
# and ulimit -r will stay 0.
echo "[3/4] Ensuring PAM includes pam_limits.so (so limits.d is applied)..."

add_pam_limits_line() {
  local pam_file="$1"
  if [[ ! -f "$pam_file" ]]; then
    echo "  - WARN: $pam_file not found, skipping."
    return
  fi

  if grep -qE '^\s*session\s+.*pam_limits\.so' "$pam_file"; then
    echo "  - OK: pam_limits.so already present in $pam_file"
  else
    echo "  - Adding 'session required pam_limits.so' to $pam_file"
    echo "session required pam_limits.so" | sudo tee -a "$pam_file" >/dev/null
  fi
}

add_pam_limits_line "/etc/pam.d/common-session"
add_pam_limits_line "/etc/pam.d/common-session-noninteractive"
echo

# ---- 4) Write realtime limits file for the @realtime group ----
echo "[4/4] Writing realtime limits to ${LIMITS_FILE} ..."
sudo tee "${LIMITS_FILE}" >/dev/null <<'EOF'
@realtime soft rtprio 99
@realtime hard rtprio 99
@realtime soft memlock unlimited
@realtime hard memlock unlimited
EOF
echo "  - Wrote ${LIMITS_FILE}"
echo

# ---- Helpful checks ----
echo "=== Done. IMPORTANT: log out and log back in (or reboot) ==="
echo
echo "After re-login, verify:"
echo "  id | grep realtime"
echo "  ulimit -r        # should be > 0 (often 99)"
echo "  ulimit -l        # should be unlimited or very large"
echo
echo "Then relaunch your Franka ROS stack."
echo
echo "If ulimit -r is still 0 after re-login, tell me whether you start ROS via:"
echo "  - GUI terminal / SSH / TTY / systemd service / Docker"
echo "because systemd or containers need extra settings."

