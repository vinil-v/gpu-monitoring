# Navigate to the Downloads folder
cd ~/Downloads

# Download the Telegraf ZIP file
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.32.0_windows_amd64.zip -UseBasicParsing -OutFile telegraf-1.32.0_windows_amd64.zip

# Extract the ZIP file to the desired destination
Expand-Archive .\telegraf-1.32.0_windows_amd64.zip -DestinationPath 'C:\Program Files\InfluxData\telegraf'

# Change directory to the extracted location
cd 'C:\Program Files\InfluxData\telegraf\'

# Copy the Telegraf executable and configuration to the root of the Telegraf folder
cp .\telegraf-1.32.0\telegraf.* .

# List the contents of the directory to verify files
dir

# Check Telegraf version
.\telegraf.exe --version

# Set the default encoding for Out-File to UTF-8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Generate a configuration file for Telegraf with CPU and Memory input and Azure Monitor output
.\telegraf.exe --input-filter cpu:mem --output-filter azure_monitor config > azm-telegraf.conf

# Define the configuration content to be appended
$starlarkConfig = @'
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

[[inputs.nvidia_smi]]
## Optional: path to nvidia-smi binary, defaults "/usr/bin/nvidia-smi"
bin_path = "C:\\Windows\\System32\\nvidia-smi.exe"

## Optional: timeout for GPU polling
# timeout = "5s"
'@

# Append the configuration to the azm-telegraf.conf file
$starlarkConfig | Out-File -FilePath 'C:\Program Files\InfluxData\telegraf\azm-telegraf.conf' -Append -Encoding utf8

# Confirm the content has been appended
Get-Content 'C:\Program Files\InfluxData\telegraf\azm-telegraf.conf'

# Replace the example config with the new generated config
cp .\azm-telegraf.conf .\telegraf.conf

# Test the configuration
.\telegraf.exe --config "C:\Program Files\InfluxData\telegraf\telegraf.conf" --test --quiet

# Install Telegraf as a Windows service
.\telegraf.exe --config "C:\Program Files\InfluxData\telegraf\telegraf.conf" service install

# Start the Telegraf service
net start telegraf

# Test the configuration once more
.\telegraf.exe --config "C:\Program Files\InfluxData\telegraf\telegraf.conf" --test --quiet