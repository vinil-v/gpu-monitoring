# Comprehensive NVIDIA GPU Monitoring for Azure N-Series VMs Using Telegraf with Azure Monitor

In today’s AI and HPC landscapes, GPU monitoring has become essential due to the complexity and high resource demands of these workloads. Effective monitoring ensures that GPUs are utilized optimally, preventing both underutilization and overutilization, which can negatively impact performance and drive up costs. By identifying bottlenecks such as memory limitations or thermal throttling, GPU monitoring allows for performance optimization, enabling smoother workflows. In cloud environments like Azure, where GPU resources can be costly, monitoring plays a key role in managing expenses by tracking usage patterns and facilitating efficient resource allocation. Additionally, monitoring helps with capacity planning, scaling workloads, and forecasting, ensuring that resources are properly allocated for future needs.

While Azure Monitor provides robust tools for tracking CPU, memory, storage, and network usage, it **does not natively support GPU monitoring** for Azure N-series VMs. To track GPU performance, additional configuration through third-party tools or integrations—such as Telegraf—is required. At the time of writing, Azure Monitor lacks built-in GPU metrics without these external solutions.

In this guide, we will explore how to configure Telegraf to send GPU monitoring metrics to Azure Monitor. This comprehensive guide will cover all the necessary steps to enable GPU monitoring, ensuring you can track and optimize GPU performance in Azure effectively.

## Step 1: Preparing Azure for GPU Metrics

1. **Register the Microsoft.Insights Resource Provider** in your Azure subscription.  
   Refer to the [Resource providers and resource types - Azure Resource Manager](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types) for more information.

2. **Enable Managed Service Identities** to authenticate an Azure VM or Azure VMSS. You could also use User Managed Identities or Service Principal for authentication.  
   Refer to the [Telegraf Azure Monitor Output Plugin Documentation](https://github.com/influxdata/telegraf/tree/release-1.15/plugins/outputs/azure_monitor).

## Step 2: Set Up the Telegraf Agent Inside the VM or VMSS

### Linux
I will use an Azure Standard_ND96asr_v4 VM with the Ubuntu-HPC 2204 image to configure the environment for both VM and VMSS. The Ubuntu-HPC 2204 image comes pre-installed with NVIDIA GPU drivers and CUDA. If you choose to use a different image, make sure to install the necessary GPU drivers and the CUDA toolkit.

Download and execute the `gpumon-setup.sh` script to install the Telegraf agent on Ubuntu 22.04. This script will also configure the NVIDIA SMI input plugin and set up the Telegraf configuration to send data to Azure Monitor.

Run the following commands:

```bash
wget -q https://raw.githubusercontent.com/vinil-v/gpu-monitoring/refs/heads/main/scripts/gpumon-setup.sh -O gpumon-setup.sh
chmod +x gpumon-setup.sh
./gpumon-setup.sh
```

Test the Telegraf configuration by executing the following command:

```bash
sudo telegraf --config=/etc/telegraf/telegraf.conf --test
```
### Windows

To set up Telegraf for GPU monitoring on Windows, follow these steps:

1. **Open PowerShell as Administrator**:
   - Search for "PowerShell" in the Start menu.
   - Right-click on **Windows PowerShell** and select **Run as administrator**.

2. **Execute the following commands**:
   Copy and paste the following commands into the PowerShell window to download and run the Telegraf setup script for GPU monitoring.

   ```powershell
   # Set the URL for the PowerShell script
   $scriptUrl = "https://raw.githubusercontent.com/vinil-v/gpu-monitoring/refs/heads/main/scripts/gpumon-win.ps1"

   # Download and execute the script
   Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing | Invoke-Expression
   ```

This script will automatically download, configure, and install Telegraf with GPU monitoring on your Windows machine.

## Step 3: Creating Dashboards in Azure Monitor to Check NVIDIA GPU Usage

Telegraf includes an output plugin specifically designed for Azure Monitor, enabling users to send custom metrics directly to the platform. Azure Monitor functions with a metric resolution of one minute; thus, the Telegraf output plugin automatically aggregates metrics into one-minute buckets, which are sent to Azure Monitor at each flush interval. Each input plugin's metrics are recorded in a separate Azure Monitor namespace, defaulting to the prefix "Telegraf/" for easy identification.

To visualize NVIDIA GPU usage, navigate to the Metrics section in the Azure portal. Select the VM name as the scope, and then choose the Metric Namespace as `telegraf/nvidia-smi`. From there, you can select various metrics to view NVIDIA GPU utilization. You can also apply filters and splits for a more detailed analysis of the data.

You can create GPU monitoring dashboards for both VM and VMSS. Below are some sample charts to consider.

## Bonus: Simulating GPU Usage Using a Sample Training Program

If you're testing and lack a program to simulate GPU usage, I have a solution for you! I've created a script that runs a multi-GPU distributed training model. This script will install the Anaconda software and set up the environment needed for executing the distributed training model using TensorFlow. By running this script, you can effectively simulate GPU usage, allowing you to verify the monitoring metrics you’ve set up.

To get started, run the following commands:

```bash
wget -q https://raw.githubusercontent.com/vinil-v/gpu-monitoring/refs/heads/main/scripts/gpu_test_program.sh -O gpu_test_program.sh
chmod +x gpu_test_program.sh
./gpu_test_program.sh
```

I hope you find this guide helpful. With the right tools and insights, you can unlock the full potential of your GPU resources and enhance your AI and HPC workloads.

## References

- [Ubuntu HPC on Azure Marketplace](https://azuremarketplace.microsoft.com/en-gb/marketplace/apps/microsoft-dsvm.ubuntu-hpc?tab=PlansAndPrice)
- [ND Series Specifications](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndasra100v4-series?tabs=sizebasic)
- [Telegraf Azure Monitor Output Plugin Documentation](https://github.com/influxdata/telegraf/tree/release-1.15/plugins/outputs/azure_monitor)
- [Telegraf NVIDIA SMI Input Plugin Documentation](https://github.com/influxdata/telegraf/tree/release-1.15/plugins/inputs/nvidia_smi)
