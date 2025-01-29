# Use the official CUDA base image with Python 3.8
FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04

# Set the working directory inside the container
WORKDIR /workspace

# Install Python 3.8, pip, and essential dependencies
RUN apt-get update && \
    apt-get install -y python3.8 python3.8-dev python3-pip python3.8-venv git curl wget unzip && \
    apt-get install -y build-essential nano sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    # nano sudo 
    # rm -rf /var/lib/apt/lists/*

# Ensure that python3.8 is the default python version
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install Jupyter Notebook
RUN pip install jupyterlab

# Expose port 8888 to access Jupyter Notebook
EXPOSE 8888


# # Add new user sudo 権限を付与
# RUN groupadd --gid 1000 user && \
#     useradd --uid 1000 --gid 1000 -m user && \
#     usermod -aG sudo user && \
#     echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user && \
#     chmod 0440 /etc/sudoers.d/user


# # Set the working directory
# WORKDIR /workspace
# RUN chown -R 1000:1000 /workspace    


# # Set the user
# USER user

# Set environment variables
ARG USER_ID=1000
ARG GROUP_ID=1000

# Create a group and user with specified UID/GID
RUN groupadd -g $GROUP_ID mygroup && \
    useradd -m -u $USER_ID -g mygroup myuser && \
    mkdir -p /workspace && \
    chmod -R 777 /workspace && \
    chown -R myuser:mygroup /workspace

# Set working directory
WORKDIR /workspace

# Switch to non-root user
USER myuser


#, "--NotebookApp.token=''"   to remove the server password
# Set the entrypoint to launch Jupyter Notebook
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]    
