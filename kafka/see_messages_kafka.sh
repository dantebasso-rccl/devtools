#!/bin/bash

## Author: Jose Padilha (joseluispadilla@rccl.com)
## Creation: 13/12/2024
## Version: 1.0

#original:
#kcat -b <broker:port> -t <topic_name> -p 0 -o beginning -e -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN -X sasl.username=<username>  -X sasl.password=<password> -X enable.ssl.certificate.verification=false -C


# Função para exibir uso
usage() {
    echo "Usage: $0 -brokerurl <broker> -port <port> -topic <topic_name> -username <username> -password <password>"
    exit 1
}

# Inicializar variáveis
BROKERURL=""
PORT=""
TOPIC=""
USERNAME=""
PASSWORD=""

# Parsing de argumentos
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

# Verificar se todos os parâmetros obrigatórios foram fornecidos
if [[ -z "$BROKERURL" || -z "$PORT" || -z "$TOPIC" || -z "$USERNAME" || -z "$PASSWORD" ]]; then
    echo "Error: All parameters are mandatory."
    usage
fi

# Construir comando kcat
COMMAND="kcat -b ${BROKERURL}:${PORT} -t ${TOPIC} -p 0 -o beginning -e \
    -X security.protocol=SASL_SSL \
    -X sasl.mechanisms=PLAIN \
    -X sasl.username=${USERNAME} \
    -X sasl.password=${PASSWORD} \
    -X enable.ssl.certificate.verification=false -C"

# Executar comando
if ! eval $COMMAND; then
    echo "Error: Failed to execute kcat. Please check your parameters and try again."
    exit 1
fi
