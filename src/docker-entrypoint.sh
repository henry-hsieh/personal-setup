#!/bin/sh
# Read UID and GID from env (or default to 1000)
USER_ID=${TARGET_UID:-1000}
GROUP_ID=${TARGET_GID:-1000}
USER_NAME=${TARGET_USER:-runner}
USER_HOME=${TARGET_HOME:-/home/$USER_NAME}

# Create group if missing
if ! getent group "$GROUP_ID" >/dev/null; then
    groupadd -g "$GROUP_ID" "$USER_NAME"
fi

# Create user if missing
if ! id -u "$USER_ID" >/dev/null 2>&1; then
    useradd -M -d $USER_HOME -u "$USER_ID" -g "$GROUP_ID" -s /bin/bash "$USER_NAME"
fi

# Give passwordless sudo
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/$USER_NAME
chmod 0440 /etc/sudoers.d/$USER_NAME

# Switch to the user
exec sudo -E -u "$USER_NAME" env PATH=$PATH HOME=$USER_HOME "$@"
