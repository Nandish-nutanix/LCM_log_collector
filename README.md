# LCM Log Collector Script

A Bash script, `lcm_log_collector.sh`, has been created to automate the process of log collection and transfer for internal use. This tool streamlines multiple manual steps and ensures a more efficient workflow.

## Download

Download the script here: [lcm_log_collector.sh](https://raw.githubusercontent.com/Nandish-nutanix/LCM_log_collector/main/lcm_log_collector.sh)

## How to Run the Script

### Usage Format
```bash
./lcm_log_collector.sh <PC or PE> <IP Address> [Optional: <JIRA Ticket ID or Folder Name>]
```

### Arguments
- `<PC or PE>`: Specify the target type.
- `<IP Address>`: Provide the IP address.
- `[Optional: <JIRA Ticket ID or Folder Name>]`: If omitted, the log file is stored in `logs_<IP_Address>`.

### Example Command
```bash
./lcm_log_collector.sh PC 10.120.98.68 nandish_logs
```

This saves the log file at: `http://10.41.26.34/logs/nandish_logs/`

## Steps Performed by the Script

### 1. Collect Logs
- SSH into the CVM and execute:
  ```bash
  ~/cluster/bin/lcm/lcm_log_collector
  ```

### 2. Transfer Logs
- Use `scp` to copy the log bundle to the filer VM:
  ```bash
  scp /home/nutanix/data/log_collector/<log_file_name>.tar.gz nutest@10.41.26.34:/tmp/
  ```

### 3. Access Filer VM
- SSH into the filer VM:
  ```bash
  ssh nutest@10.41.26.34
  ```

### 4. Organize and Secure Logs
- Navigate to `/var/www/html/logs/`
- Create a folder for the bug ID and move the log file:
  ```bash
  sudo mkdir -p <bugid>
  cd <bugid>
  sudo mv /tmp/<log_file_name> .
  sudo chmod 777 <log_file_name>
  ```

### 5. Share Log URL
- Access the web URL and copy the log file link for sharing.

