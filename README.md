> [!NOTE]
> This example and source code is taken from Microsoft Documentations for FREE demo and learning purposes. 

# Online Store

This sample app consists of a group of containerized microservices that can be easily deployed into Kubernetes. This is meant to show a realistic scenario using a polyglot architecture, event-driven design, and common open source back-end services (eg - RabbitMQ). 


> [!NOTE]
> This is not meant to be an example of perfect code to be used in production, but more about showing a realistic application running in Kubernetes. 

## Architecture

The application has the following services: 

| Service | Description |
| --- | --- |
| `order-service` | This service is used for placing orders (Javascript) |
| `product-service` | This service is used to perform CRUD operations on products (Rust) |
| `store-front` | Web app for customers to place orders (Vue.js) |
| `rabbitmq` | RabbitMQ for an order queue |

![Logical Application Architecture Diagram](assets/store-architecture.png)

## Build and Run Docker images

  1. Install Docker Desktop
  2. Create the microservices/applications 
  3  Create Docker files.
  4. Build and Run the images

## Run the app locally using Docker Compose

  1. Create Docker Compose file
  2. Run the apps using docker compose up
  3. Stop the app using `CTRL+C`  or using docker compose down from another terminal

## Run on Local Kubernetes (Minikube)

## Run on Local Kubernetes (KinD)

## Run the app on Azure Kubernetes Service (AKS)