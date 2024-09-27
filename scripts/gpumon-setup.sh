#!/bin/bash

# This script installs the Telegraf agent on an Azure VM with NVIDIA GPUs
# and configures it to collect GPU metrics using the nvidia_smi input plugin
# and send the metrics to Azure Monitor using the Azure Monitor output plugin.
# The script also configures the Starlark processor to convert memory metrics from MB to GB.
# The script assumes that the NVIDIA GPU drivers and CUDA are already installed on the VM.
# The script should be run with root privileges.

# Author:  Vinil Vadakkepurakkal
# Date:    27/09/2024
# Version: 1.0

# VM SKU: Standard_ND96asr_v4
# Source image publisher : microsoft-dsvm
# Source image offer: ubuntu-hpc
# Source image plan : 2204-gen2

# download the package to the VM
echo "Downloading the Telegraf package..."
curl -s https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
sudo echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo curl -fsSL https://repos.influxdata.com/influxdata-archive_compat.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg add
#Install the Package
sudo apt-get update
sudo apt-get install telegraf -y
echo "Telegraf package installed successfully"
# generate the new Telegraf config file in the current directory
echo " Generating the new Telegraf configuration file..."
telegraf --input-filter cpu:mem --output-filter azure_monitor config > azm-telegraf.conf

# add the nvidia_smi input plugin to the config file
cat << EOF >> azm-telegraf.conf
# Starlark processor configuration
[[processors.starlark]]
  source = '''
def apply(metric):
    # Iterate through the fields in the metric
    for key, value in metric.fields.items():
        # If the key relates to memory fields, convert MB to GB
        if "memory" in key and type(value) == "int":
            # Convert MB to GB by dividing by 1024
            metric.fields[key] = float(value) / 1024
        # Check if the field is an integer and convert to float
        elif type(value) == "int":
            metric.fields[key] = float(value)
    return metric
'''

# NVIDIA SMI input configuration
[[inputs.nvidia_smi]]
  bin_path = "/usr/local/cuda/bin/nvidia-smi"

  timeout = "5s"
EOF
# replace the example config with the new generated config
sudo cp azm-telegraf.conf /etc/telegraf/telegraf.conf
echo " New Telegraf configuration file generated and copied to /etc/telegraf/telegraf.conf"
echo " Restarting the Telegraf agent to apply the new configuration..."
# stop the telegraf agent on the VM
sudo systemctl stop telegraf
# start and enable the telegraf agent on the VM to ensure it picks up the latest configuration
sudo systemctl enable --now telegraf
echo " Telegraf agent restarted successfully"