> [!NOTE]
> This example and source code is taken from Microsoft Documentations for FREE demo and learning purposes. 

# Online Store

This sample app consists of a group of containerized microservices that can be easily deployed into Kubernetes. This is meant to show a realistic scenario using a polyglot architecture, event-driven design, and common open source back-end services (eg - RabbitMQ). 


> [!NOTE]
> This is not meant to be an example of perfect code to be used in production, but more about showing a realistic application running in Kubernetes. 

# Architecture

The application has the following services: 

| Service | Description |
| --- | --- |
| `order-service` | This service is used for placing orders (Javascript) |
| `product-service` | This service is used to perform CRUD operations on products (Rust) |
| `store-front` | Web app for customers to place orders (Vue.js) |
| `rabbitmq` | RabbitMQ for an order queue |

![Logical Application Architecture Diagram](assets/store-architecture.png)

# Microservices

Microservices (or microservice architecture) is a software design approach where an application is built as a collection of small, 
independent services that communicate with each other using lightweight protocols (usually HTTP/REST, gRPC, or messaging queues).

Each microservice:

  Runs in its own process.
  Is independently deployable & scalable.
  Owns its data & logic (usually with its own database).
  Focuses on a specific business capability (e.g., authentication, messaging, product, order processing).

Advantages of Microservices over Monolithic

  Scalability – Scale only the required service instead of the whole app.
  Flexibility – Different service can use different programming languages, databases, frameworks.
  Resilience – Failure in one microservice doesn’t take down the whole system.
  Faster Development & Deployment – Teams work independently, allowing for CI/CD and faster releases.
  Reusability – Microservices can be reused across different projects.
  Easier Maintenance – Smaller codebases are easier to manage and test.

# Build and Run Docker images

  ## 1. Install Docker Desktop

      Windows: https://docs.docker.com/desktop/setup/install/windows-install/
      Linux:   https://docs.docker.com/desktop/setup/install/linux/
      Mac:     https://docs.docker.com/desktop/setup/install/mac-install/

      More Links:

      Docker Installation Steps in Windows & Mac OS
              https://medium.com/@javatechie/docker-installation-steps-in-windows-mac-os-b749fdddf73a

      How to Install Docker on Windows
              https://medium.com/@supportfly/how-to-install-docker-on-windows-bead8c658a68

      Step-by-Step Tutorial: Installing Docker and Docker Compose on Ubuntu
              https://tomerklein.dev/step-by-step-tutorial-installing-docker-and-docker-compose-on-ubuntu-a98a1b7aaed0

  ## 2. Create the microservices/applications 

        RabbitMQ: Message broker, provides the messaging backbone. Should run first.

        Order-service: Consumes/Produces messages via RabbitMQ.Connects to RabbitMQ for 
        handling order messages.

        Product-service: Provides product-related APIs/data.

        Store-front: frontend gateway that depends on both product and order services. 
        This is the entry point for users. It calls product-service (for catalog) and 
        order-service (for placing orders).

        All communication happens inside the private network backend_services.
        backend_services: A custom bridge network where all services can communicate with each other by service name 
        (e.g., rabbitmq, order-service).

  ## 3  Create Docker files 

        A Dockerfile is a text file that contains a set of instructions for building a Docker image.

        Essential Instructions

          FROM → defines the base image.

          RUN → runs commands (e.g., install software).

          CMD → sets the default command when the container runs.

          ENTRYPOINT → defines the main command that always runs, even if you pass arguments.

          WORKDIR → sets the working directory inside the container.
          
        File & Directory Management

          COPY → copies files from host into the image.

          ADD → like COPY, but also supports remote URLs and automatic archive extraction (e.g., .tar.gz).

          VOLUME → creates a mount point for persistent data or shared volumes.

        Configuration & Environment

          ENV → sets environment variables.

          ARG → defines build-time variables (different from ENV because these don’t persist at runtime unless passed).

          LABEL → adds metadata to the image (author, version, description).

          USER → sets the user to run commands as (instead of root).

          SHELL → changes the default shell used in RUN commands (e.g., ["powershell", "-Command"] on Windows).

        Networking & Ports

            EXPOSE → documents which ports the container will listen on (note: it doesn’t actually publish the port).

        Build Optimizations

            ONBUILD → triggers instructions when the image is used as a base for another build.

            STOPSIGNAL → sets the system call signal used to stop the container.

            HEALTHCHECK → defines a command for checking container health (e.g., ping a service).

        Security & Permissions

            USER → runs commands as a specific user/group.

            CHOWN (used in COPY/ADD) → sets ownership of copied files.

  ## Docker Commands

      Docker Basics
      # Check Docker version
      docker --version
      docker info

      # Get help
      docker --help

      Images
      # List images
      docker images

      # Pull an image
      docker pull <image_name>:<tag>

      # Remove an image
      docker rmi <image_id>

      # Build an image from Dockerfile
      docker build -t <image_name>:<tag> .

      # Tag an image
      docker tag <image_id> <new_name>:<tag>

      Containers
      # List running containers
      docker ps

      # List all containers (including stopped)
      docker ps -a

      # Run a container
      docker run -d --name <container_name> <image_name>

      # Run interactively with shell
      docker run -it <image_name> /bin/bash

      # Start/Stop container
      docker start <container_id>
      docker stop <container_id>

      # Restart container
      docker restart <container_id>

      # Remove container
      docker rm <container_id>

      # Logs
      docker logs -f <container_id>

      # Execute command in running container
      docker exec -it <container_id> /bin/bash

      Volumes & Data
      # List volumes
      docker volume ls

      # Create volume
      docker volume create <volume_name>

      # Mount volume
      docker run -v <volume_name>:/path/in/container <image_name>

      Networking
      # List networks
      docker network ls

      # Create network
      docker network create <network_name>

      # Connect container to network
      docker network connect <network_name> <container_id>

      # Disconnect container from network
      docker network disconnect <network_name> <container_id>

      Docker Compose
      # Start services
      docker-compose up -d

      # Stop services
      docker-compose down

      # Restart services
      docker-compose restart

      # View logs
      docker-compose logs -f

      Cleanup
      # Remove stopped containers
      docker container prune

      # Remove unused images
      docker image prune

      # Remove unused volumes
      docker volume prune

      # Remove everything unused
      docker system prune -a

  ## 4. Build and Run the images

        Start the Docker Engine 

        # Order Service
        docker build -t order ./src/order-service 
        docker tag order:latest $ACR_NAME.azurecr.io/order:v1
        docker push $ACR_NAME.azurecr.io/order:v1

        # Product Service
        docker build -t product ./app/product-service 
        docker tag product:latest $ACR_NAME.azurecr.io/product:v1
        docker push $ACR_NAME.azurecr.io/product:v1

        # Store Front Service
        docker build -t store-front ./app/store-front 
        docker tag store-front:latest $ACR_NAME.azurecr.io/store-front:v1
        docker push $ACR_NAME.azurecr.io/store-front:v1

        docker images



# Run the app locally using Docker Compose

  1. Create Docker Compose file
  2. Run the apps using docker compose up
  3. Stop the app using `CTRL+C`  or using docker compose down from another terminal

# Run on Local Kubernetes (Minikube)

# Run on Local Kubernetes (KinD)

# Run the app on Azure Kubernetes Service (AKS)


1️⃣ Create a custom network

All your services are on the backend_services network:

docker network create backend_services

2️⃣ Run RabbitMQ
docker run -d \
  --name rabbitmq \
  --restart always \
  --network backend_services \
  -p 15672:15672 \
  -p 5672:5672 \
  -e RABBITMQ_DEFAULT_USER=username \
  -e RABBITMQ_DEFAULT_PASS=password \
  -v $(pwd)/rabbitmq_enabled_plugins:/etc/rabbitmq/enabled_plugins \
  rabbitmq:3.13.2-management-alpine


Note: Health checks can’t be enforced automatically like Compose, but you can check manually with:
docker exec rabbitmq rabbitmqctl status

3️⃣ Run Order Service

Since it depends on RabbitMQ, you should wait until RabbitMQ is healthy (or just sleep a few seconds).

docker run -d \
  --name order-service \
  --restart always \
  --network backend_services \
  -p 3000:3000 \
  -e ORDER_QUEUE_HOSTNAME=rabbitmq \
  -e ORDER_QUEUE_PORT=5672 \
  -e ORDER_QUEUE_USERNAME=username \
  -e ORDER_QUEUE_PASSWORD=password \
  -e ORDER_QUEUE_NAME=orders \
  -e ORDER_QUEUE_RECONNECT_LIMIT=3 \
  order-service-image


Replace order-service-image with the image name you build from src/order-service:

docker build -t order-service-image src/order-service

4️⃣ Run Product Service
docker run -d \
  --name product-service \
  --restart always \
  --network backend_services \
  -p 3002:3002 \
  product-service-image


Build it first:

docker build -t product-service-image src/product-service

5️⃣ Run Store Front

Depends on order-service and product-service, so wait a few seconds for them to start:

docker run -d \
  --name store-front \
  --restart always \
  --network backend_services \
  -p 8080:8080 \
  store-front-image


Build it first:

docker build -t store-front-image src/store-front

✅ Notes / Caveats

Health Checks: Docker Compose automatically waits for services to be healthy. With docker run, you need manual checks or scripts (docker inspect --format='{{.State.Health.Status}}' <container>).

Depends_on: Not supported in docker run. You handle this by manually waiting or using a script to check health.

Volumes: Only RabbitMQ uses one volume. Others are just built images.

Network: All containers must use the same backend_services network to communicate by container name.