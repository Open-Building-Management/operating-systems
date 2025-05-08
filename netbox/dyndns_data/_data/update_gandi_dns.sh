#!/bin/sh

# === Variables ===
DOMAIN="${DOMAIN:-dromotherm.com}"
RECORD_NAMES="${RECORD_NAME:-netbox}"  # one or more record(s) separated by a blank space
TTL="${TTL:-300}"       # DEFAULT TTL (in seconds)
INTERVAL="${INTERVAL:-600}"  # Update interval (in seconds)

# Volumes and files
DATA_DIR="${DATA_DIR:-/data}"
TOKEN_FILE="${TOKEN_FILE:-$DATA_DIR/gandi_ddns_token}"
IP_FILE="${IP_FILE:-$DATA_DIR/${DOMAIN//./_}-current_ip.txt}"
COUNTER_FILE="${COUNTER_FILE:-$DATA_DIR/${DOMAIN//./_}-gandi_ddns_counter.txt}"

# Folder creation if needed
mkdir -p "$DATA_DIR"

# Counter initialisation
[ -f "$COUNTER_FILE" ] || echo 0 > "$COUNTER_FILE"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "[$(date)] ERROR: No Token in $TOKEN_FILE"
    exit 1
fi
TOKEN=$(cat "$TOKEN_FILE")

if ! command -v curl > /dev/null; then
    echo "[$(date)] Install curl / ca-certificates..."
    apk add --no-cache curl ca-certificates
fi

while true; do
    # get the public WAN IP
    CURRENT_IP=$(curl -s https://api.ipify.org)
    echo "[$(date)] CURRENT IP : $CURRENT_IP"
    if ! echo "$CURRENT_IP" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "[$(date)] ERROR: INVALID IP : $CURRENT_IP"
        exit 1
    fi

    if [ ! -f "$IP_FILE" ] || [ "$CURRENT_IP" != "$(cat "$IP_FILE")" ]; then
        echo "[$(date)] NEW IP : $CURRENT_IP"
        SUCCESS=1

        for NAME in $RECORD_NAMES; do
            echo "[$(date)] Updating DNS for $NAME.$DOMAIN"

            RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
                "https://api.gandi.net/v5/livedns/domains/$DOMAIN/records/$NAME/A" \
                -H "Authorization: Bearer $TOKEN" \
                -H "Content-Type: application/json" \
                --data "{\"rrset_values\": [\"$CURRENT_IP\"], \"rrset_ttl\": $TTL}")

            if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "201" ]; then
                echo "[$(date)] SUCCESS: $NAME.$DOMAIN updated"
            else
                echo "[$(date)] FAILURE: $NAME.$DOMAIN not updated (HTTP $RESPONSE)"
                SUCCESS=0
            fi
        done

        if [ "$SUCCESS" -eq 1 ]; then
            echo "$CURRENT_IP" > "$IP_FILE"
            COUNT=$(cat "$COUNTER_FILE")
            echo $((COUNT + 1)) > "$COUNTER_FILE"
            echo "[$(date)] ALL RECORDS UPDATED SUCCESSFULLY #$((COUNT + 1))"
        fi
    else
        echo "[$(date)] IP STILL VALID ($CURRENT_IP)"
    fi
    sleep "$INTERVAL"
done
