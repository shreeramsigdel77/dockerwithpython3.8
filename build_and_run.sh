#!/bin/bash

# Set variables for service name and host directory
SERVICE_NAME="cudapy_docker"  # Replace with the service name in your docker-compose.yml
HOST_DIRECTORY="//home/shreeram/workspace/experimental_dockerimages/docker_python3.8/"  # Replace with your host directory path
CONTAINER_WORKSPACE="/workspace"  # Path in the container to mount

# Step 1: Build the Docker image using docker-compose
echo "Building the Docker image using docker-compose..."
docker-compose build # Uncomment --no-cache if you want to rebuild from scratch
# docker-compose build --no-cache  # Uncomment this line if you want to disable the cache

# Check if the build was successful
if [ $? -eq 0 ]; then
  echo "Docker image built successfully!"
else
  echo "Error: Docker image build failed."
  exit 1
fi

# Step 2: Start the Docker container in detached mode
echo "Starting the container in detached mode..."
docker-compose up -d

# Check if the container started successfully
if [ $? -eq 0 ]; then
  echo "Docker container is running in detached mode."
else
  echo "Error: Docker container failed to start."
  exit 1
fi

# Step 3: Execute a bash shell inside the running container
echo "Executing bash shell inside the container..."
docker-compose exec $SERVICE_NAME /bin/bash  # Replace with your actual service name in docker-compose.yml

# Check if bash shell execution was successful
if [ $? -eq 0 ]; then
  echo "You are now inside the Docker container. You can run your commands."
else
  echo "Error: Failed to execute bash shell inside the container."
  exit 1
fi
