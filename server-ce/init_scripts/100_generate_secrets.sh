#!/bin/bash
set -e -o pipefail

# Define file paths
WEB_API_PASSWORD_FILE=/etc/container_environment/WEB_API_PASSWORD
STAGING_PASSWORD_FILE=/etc/container_environment/STAGING_PASSWORD
V1_HISTORY_PASSWORD_FILE=/etc/container_environment/V1_HISTORY_PASSWORD
CRYPTO_RANDOM_FILE=/etc/container_environment/CRYPTO_RANDOM
OT_JWT_AUTH_KEY_FILE=/etc/container_environment/OT_JWT_AUTH_KEY

generate_secret () {
    dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -d '\n+/'
}

# Function to sync env var to file if var is set
sync_secret () {
    local var_name=$1
    local file_path=$2
    
    if [ ! -z "${!var_name}" ]; then
        echo "Using provided environment variable for $var_name"
        echo -n "${!var_name}" > "$file_path"
    elif [ ! -f "$file_path" ]; then
        echo "Generating random secret for $var_name"
        generate_secret > "$file_path"
    fi
}

# Sync each secret
sync_secret "WEB_API_PASSWORD" "$WEB_API_PASSWORD_FILE"
sync_secret "STAGING_PASSWORD" "$STAGING_PASSWORD_FILE"

# v1_history usually shares the staging password
if [ ! -z "$STAGING_PASSWORD" ]; then
    echo -n "$STAGING_PASSWORD" > "$V1_HISTORY_PASSWORD_FILE"
fi

sync_secret "CRYPTO_RANDOM" "$CRYPTO_RANDOM_FILE"
sync_secret "OT_JWT_AUTH_KEY" "$OT_JWT_AUTH_KEY_FILE"
