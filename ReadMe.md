To allow the Docker container to read and write files in the same path as the host machine, and maintain read/write permissions for both the host and Docker container (while using root permissions), you can bind mount a host directory to a container directory.

Here’s an updated Dockerfile with the necessary steps to ensure proper permissions:

### Dockerfile:

```Dockerfile
# Use the official CUDA base image with Python 3.8
FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04

# Set the working directory inside the container
WORKDIR /workspace

# Install Python 3.8, pip, and essential dependencies
RUN apt-get update && \
    apt-get install -y python3.8 python3.8-dev python3-pip python3.8-venv && \
    apt-get install -y build-essential && \
    apt-get clean

# Ensure that python3.8 is the default python version
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install Jupyter Notebook
RUN pip install jupyterlab

# Expose port 8888 to access Jupyter Notebook
EXPOSE 8888

# Set the entrypoint to launch Jupyter Notebook
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
```

### Running the Docker container with a host directory mount:

1. **Create a host directory** for shared files:

   ```bash
   mkdir /path/to/host/directory
   ```
2. **Run the container** with a volume mount to share the host directory with the container:

   ```bash
   docker run --gpus all -p 8888:8888 -v /path/to/host/directory:/workspace -u root python-cuda-jupyter
   ```

   * The `-v /path/to/host/directory:/workspace` option binds the host directory `/path/to/host/directory` to the `/workspace` directory inside the Docker container.
   * The `-u root` option ensures the Docker container runs as the `root` user, granting read/write access to both the container and the host directory.
3. **Verify permissions** :

* The container will now have full access to read/write files in `/path/to/host/directory` on the host machine. Any file operations done inside the container (through Jupyter or manually) will be reflected on the host system in this directory.

1. **Access Jupyter Notebook** :

* You can now access Jupyter Notebook at `http://localhost:8888`. Files in `/workspace` inside the container are the same as those in `/path/to/host/directory` on the host machine.

### Notes:

* Make sure that the host machine directory `/path/to/host/directory` has appropriate read/write permissions for the `root` user. The Docker container will run as root, so the permissions of the host directory should allow `root` access.
* If needed, you can adjust permissions on the host directory like this:
  ```bash
  sudo chown -R $USER:$USER /path/to/host/directory
  sudo chmod -R 777 /path/to/host/directory
  ```

This setup ensures that the host and the Docker container can both read and write files to the same directory, while maintaining the necessary permissions for root.



Here’s an updated version of your `.sh` script that combines the features from your initial script with the new `docker-compose` setup. The script will handle building the Docker image, starting the container in detached mode, and then executing a bash shell inside the container. It also checks the success of each step and provides error handling:

### Updated `docker-compose-build-run.sh`:

```bash
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
```

### Changes Made:

1. **Service Name Variable** : The `SERVICE_NAME` variable is defined at the top for easier configuration. Replace `"cudapy_docker"` with the name of your service as specified in `docker-compose.yml`.
2. **Host Directory** : The host directory variable (`HOST_DIRECTORY`) and container workspace (`CONTAINER_WORKSPACE`) are set for mounting in the `docker-compose.yml` volume section if needed. Adjust this path according to your system.
3. **Step 1 - Build Image** : The script builds the image using `docker-compose build`. You can uncomment `--no-cache` if you want to avoid using the cache during the build process.
4. **Step 2 - Start Container** : After building the image, the script brings the container up in detached mode (`docker-compose up -d`).
5. **Step 3 - Execute Bash Shell** : The script enters the running container using `docker-compose exec` and launches a `bash` shell. If this fails, it will print an error message.

### Steps to Use the Updated Script:

1. **Save the script** :
   Save the above script as `docker-compose-build-run.sh`.
2. **Make the script executable** :

```bash
   chmod +x docker-compose-build-run.sh
```

1. **Run the script** :

```bash
   ./docker-compose-build-run.sh
```

This script now combines the benefits of your original script with the `docker-compose` flow and adds necessary checks and error handling. Let me know if you need further modifications!




You may need to insert password to enter into the docker : in that case just

```
run docker ps -a 
```

out side of container and you will get the container id


```
docker logs docker_container_id
```

Look for Notebook  server where you can find the token copy and paste that into the Token field  and set the new password
