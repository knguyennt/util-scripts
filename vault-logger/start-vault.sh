#!/bin/bash
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "❌ .env file not found!"
  exit 1
fi


docker run --rm -p $PORT:$PORT --cap-add=IPC_LOCK -d --name $CONTAINER_NAME -e "VAULT_DEV_ROOT_TOKEN_ID=$VAULT_TOKEN" -e "VAULT_DEV_LISTEN_ADDRESS=$HOST:$PORT" -e VAULT_ADDR='http://127.0.0.1:8200' $IMAGE_NAME
sleep 5
docker exec $CONTAINER_NAME vault login $VAULT_TOKEN
docker exec $CONTAINER_NAME vault kv put secret/logger ${TOKEN_SECRET_NAME}=${TOKEN_SECRET_VALUE}

echo "🌐 Starting ngrok tunnel..."
ngrok http --url=${NGROK_HOST} ${PORT}