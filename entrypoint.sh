#!/bin/sh
set -e

# Read secrets from Docker secrets mount point
EMAIL_ADDRESS=$(cat /run/secrets/email_address)
EMAIL_USERNAME=$(cat /run/secrets/email_username)
EMAIL_APIKEY=$(cat /run/secrets/email_apikey)
RECEIVER_NAME=$(cat /run/secrets/receiver_name)

# Replace placeholders in template with actual secret values
sed -e "s|__EMAIL_ADDRESS__|${EMAIL_ADDRESS}|g" \
    -e "s|__EMAIL_USERNAME__|${EMAIL_USERNAME}|g" \
    -e "s|__EMAIL_APIKEY__|${EMAIL_APIKEY}|g" \
    -e "s|__RECEIVER_NAME__|${RECEIVER_NAME}|g" \
    /etc/alertmanager/alertmanager.yml.template > /etc/alertmanager/alertmanager.yml

# Verify the config was generated
if [ ! -f /etc/alertmanager/alertmanager.yml ]; then
    echo "Error: Failed to generate alertmanager.yml"
    exit 1
fi

echo "AlertManager configuration generated successfully"

# Start AlertManager with the generated config
exec /bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml \
    --storage.path=/alertmanager \
    --web.external-url=http://localhost:9093
