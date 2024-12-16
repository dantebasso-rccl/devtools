#!/bin/bash

## Author: Jose Padilha (joseluispadilla@rccl.com)
## Creation: 13/12/2024
## Version: 1.1

# Function to display usage
usage() {
    echo "Usage: $0 -brokerurl <broker> -port <port> -topic <topic_name> -username <username> -password <password>"
    exit 1
}

# Initialize variables
BROKERURL=""
PORT=""
TOPIC=""
USERNAME=""
PASSWORD=""

# Argument parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        -brokerurl)
            BROKERURL="$2"
            shift 2
            ;;
        -port)
            PORT="$2"
            shift 2
            ;;
        -topic)
            TOPIC="$2"
            shift 2
            ;;
        -username)
            USERNAME="$2"
            shift 2
            ;;
        -password)
            PASSWORD="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Verify if all mandatory parameters were provided
if [[ -z "$BROKERURL" || -z "$PORT" || -z "$TOPIC" || -z "$USERNAME" || -z "$PASSWORD" ]]; then
    echo "Error: All parameters are mandatory."
    usage
fi

# Check if kcat is installed
if ! command -v kcat &> /dev/null; then
    echo "kcat is not installed. Installing with Homebrew..."
    if ! brew install kafkacat; then
        echo "Error: Failed to install kcat. Please check your Homebrew installation."
        exit 1
    fi
    echo "kcat installed successfully."
fi

# Build kcat command
COMMAND="kcat -b ${BROKERURL}:${PORT} -t ${TOPIC} -p 0 -o beginning -e \
    -X security.protocol=SASL_SSL \
    -X sasl.mechanisms=PLAIN \
    -X sasl.username=${USERNAME} \
    -X sasl.password=${PASSWORD} \
    -X enable.ssl.certificate.verification=false -C"

# Execute command
if ! eval $COMMAND; then
    echo "Error: Failed to execute kcat. Please check your parameters and try again."
    exit 1
fi
