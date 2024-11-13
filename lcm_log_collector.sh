#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <PC or PE> <IP Address> [<JIRA Ticket ID or Folder Name>]"
    exit 1
fi

CHOICE=$1
NUTANIX_IP=$2
FOLDER_NAME=${3:-logs_$NUTANIX_IP}

if [ "$CHOICE" == "PC" ]; then
    PASSWORD="nutanix/4u"
    LOG_COMMAND="~/cluster/bin/lcm/lcm_log_collector"  
elif [ "$CHOICE" == "PE" ]; then
    PASSWORD="RDMCluster.123"
    LOG_COMMAND="~/cluster/bin/lcm/lcm_logbay_log_collection"  
else
    echo "Invalid choice. Please specify 'PC' or 'PE'. Exiting."
    exit 1
fi

LOG_DEST_IP="10.41.26.34"
USERNAME="nutanix"
DEST_USERNAME="nutest"
DEST_PASSWORD="nutanix/4u"
LOG_FOLDER="/var/www/html/logs/"
LOG_TMP_PATH="/tmp/"

copy_log_file () {
    LOG_PATH=$1
    FILE_NAME=$(basename $LOG_PATH)

    echo "Copying log file from Nutanix server to $LOG_DEST_IP"
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$NUTANIX_IP "sshpass -p $DEST_PASSWORD scp $LOG_PATH $DEST_USERNAME@$LOG_DEST_IP:$LOG_TMP_PATH"

    if [ $? -ne 0 ]; then
      echo "Error: SCP failed to copy the log file to the destination."
      exit 1
    fi

    sshpass -p $DEST_PASSWORD ssh -t -o StrictHostKeyChecking=no $DEST_USERNAME@$LOG_DEST_IP << ENDSSH2
        cd $LOG_FOLDER
        echo "Creating folder $FOLDER_NAME"
        echo $DEST_PASSWORD | sudo -S mkdir -p $FOLDER_NAME
        cd $FOLDER_NAME
        echo "Moving log file"
        if [ -f "$LOG_TMP_PATH$FILE_NAME" ]; then
          echo $DEST_PASSWORD | sudo -S mv $LOG_TMP_PATH$FILE_NAME .
          echo "Setting permissions for the log file"
          echo $DEST_PASSWORD | sudo -S chmod 777 $FILE_NAME
        else
          echo "Error: Log file not found at $LOG_TMP_PATH$FILE_NAME"
        fi
        echo "Log file moved and permissions set."
ENDSSH2
}

echo "Executing log collection operation..."
LOG_OUTPUT=$(sshpass -p $PASSWORD ssh -q -o StrictHostKeyChecking=no $USERNAME@$NUTANIX_IP "$LOG_COMMAND")

echo "Full SSH log collection output:"
echo "$LOG_OUTPUT"

if [ "$CHOICE" == "PE" ]; then
    LOG_PATH=$(echo "$LOG_OUTPUT" | grep 'Log collected on' | awk -F 'path: ' '{print $2}')
else
    LOG_PATH=$(echo "$LOG_OUTPUT" | grep 'Log bundle created at:' | awk '{print $5}')
fi

echo "Log path is: $LOG_PATH"

if [ -z "$LOG_PATH" ]; then
  echo "Error: Failed to retrieve log path."
  if [ "$CHOICE" == "PE" ]; then
      echo "Sometimes Host key verifications might fail. Please try running:"
      echo "ssh-keygen -R $NUTANIX_IP"
  fi
  exit 1
fi

copy_log_file "$LOG_PATH"

echo "The link is: http://$LOG_DEST_IP/logs/$FOLDER_NAME"
echo "Script completed successfully."
