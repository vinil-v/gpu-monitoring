#!/bin/bash
# This script installs Anaconda, creates a new conda environment for distributed training,
# and runs a distributed training example script using TensorFlow and Keras.
# The script assumes that the NVIDIA GPU drivers and CUDA are already installed on the VM.
# The script should be run with a non-root user account.

#Author:  Vinil Vadakkepurakkal
#Date:    27/09/2024
#Version: 1.0



# Exit immediately if any command fails
set -e

# Variables
ANACONDA_URL="https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh"
ANACONDA_INSTALL_PATH="$HOME/anaconda3"
EXAMPLE_SCRIPT_URL="https://raw.githubusercontent.com/keras-team/keras-io/5c985f57cb40bed46b39bf2aa38ad766b3380425/guides/distributed_training.py"
PYTHON_VERSION="3.6.9"
NUMPY_VERSION="1.18.5"
TENSORFLOW_GPU="tensorflow-gpu"
KERAS_GPU="keras-gpu"

# Check if Anaconda is already installed
if [ -d "$ANACONDA_INSTALL_PATH" ] && [ -x "$ANACONDA_INSTALL_PATH/bin/conda" ]; then
    echo "Anaconda is already installed at $ANACONDA_INSTALL_PATH"
else
    # Download the Anaconda package
    echo "Downloading the Anaconda package..."
    wget -q $ANACONDA_URL -O Anaconda3-2024.06-1-Linux-x86_64.sh

    # Install the Anaconda package
    echo "Installing the Anaconda package..."
    bash Anaconda3-2024.06-1-Linux-x86_64.sh -b -p $ANACONDA_INSTALL_PATH

    # Add the Anaconda path to the PATH environment variable
    echo "Adding the Anaconda path to the PATH environment variable..."
    if ! grep -q 'export PATH="$HOME/anaconda3/bin:$PATH"' "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> $HOME/.bashrc
    fi

    # Initialize the shell for conda
    echo "Initializing the shell for conda..."
    $ANACONDA_INSTALL_PATH/bin/conda init bash

    # Source the Anaconda initialization to make conda command available immediately
    source $ANACONDA_INSTALL_PATH/etc/profile.d/conda.sh
    echo "Anaconda initialized. You can continue with the installation."
fi

# Update conda and install required packages for distributed training
echo "Updating conda and installing the required packages..."
source $ANACONDA_INSTALL_PATH/etc/profile.d/conda.sh  # Ensure the new PATH is loaded

# Update conda
conda update -n base -c defaults conda -y

# Activate the base environment
echo "Activating the base environment..."
conda activate base  # Activate the base environment

# Create the training environment
echo "Creating the training environment..."
conda create -n training_env python=$PYTHON_VERSION -y

# Activate the training environment
echo "Activating the training environment..."
conda activate training_env

# Install specific versions of required packages
echo "Installing numpy, tensorflow-gpu, and keras-gpu..."
conda install -y numpy=$NUMPY_VERSION $TENSORFLOW_GPU $KERAS_GPU

# Download the distributed training example script
echo "Downloading the distributed training example script..."
wget -q $EXAMPLE_SCRIPT_URL -O distributed_training.py

# Run the distributed training example script
echo "Running the distributed training example script..."
python distributed_training.py

echo "Distributed training example script completed successfully!"