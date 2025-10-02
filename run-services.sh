#!/bin/bash
set -e

# --- CONFIG ---
NETWORK_NAME="backend_services"

# --- CREATE NETWORK ---
if ! docker network ls | grep -q "$NETWORK_NAME"; then
  echo "Creating network: $NETWORK_NAME"
  docker network create $NETWORK_NAME
else
  echo "Network $NETWORK_NAME already exists"
fi

# --- BUILD IMAGES ---
echo "Building images..."
docker build -t order-service src/order-service
docker build -t product-service src/product-service
docker build -t store-front src/store-front

# --- START RABBITMQ ---
echo "Starting RabbitMQ..."
docker run -d \
  --name rabbitmq \
  --restart always \
  --network $NETWORK_NAME \
  -p 15672:15672 \
  -p 5672:5672 \
  -e RABBITMQ_DEFAULT_USER=username \
  -e RABBITMQ_DEFAULT_PASS=password \
  -v $(pwd)/rabbitmq_enabled_plugins:/etc/rabbitmq/enabled_plugins \
  rabbitmq:3.13.2-management-alpine

# --- START ORDER-SERVICE ---
echo "Starting order-service..."
docker run -d \
  --name order-service \
  --restart always \
  --network $NETWORK_NAME \
  -p 3000:3000 \
  -e ORDER_QUEUE_HOSTNAME=rabbitmq \
  -e ORDER_QUEUE_PORT=5672 \
  -e ORDER_QUEUE_USERNAME=username \
  -e ORDER_QUEUE_PASSWORD=password \
  -e ORDER_QUEUE_NAME=orders \
  -e ORDER_QUEUE_RECONNECT_LIMIT=3 \
  order-service

# --- START PRODUCT-SERVICE ---
echo "Starting product-service..."
docker run -d \
  --name product-service \
  --restart always \
  --network $NETWORK_NAME \
  -p 3002:3002 \
  product-service

# --- START STORE-FRONT ---
echo "Starting store-front..."
docker run -d \
  --name store-front \
  --restart always \
  --network $NETWORK_NAME \
  -p 8080:8080 \
  store-front

# --- ACCESS THE APPLICATION ---
curl localhost:8080
echo "All services are up and running!"