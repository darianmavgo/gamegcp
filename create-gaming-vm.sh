#!/bin/bash
# Creates a new Windows Server 2022 instance for gaming troubleshooting.
# Automatically runs the controller troubleshooting suite on startup.

INSTANCE_NAME="win-gaming-debug"
ZONE="us-east1-d"
# Dynamically get the current project ID
PROJECT_ID=$(gcloud config get-value project)

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Could not determine Project ID. Please set it using 'gcloud config set project <PROJECT_ID>'."
    exit 1
fi

echo "Creating instance $INSTANCE_NAME in $ZONE for Project: $PROJECT_ID..."
echo "Applying startup script from setup/troubleshoot-controller.ps1..."

gcloud compute instances create $INSTANCE_NAME \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=n1-standard-4 \
    --accelerator=type=nvidia-tesla-t4,count=1 \
    --maintenance-policy=TERMINATE \
    --provisioning-model=SPOT \
    --image-project=windows-cloud \
    --image-family=windows-2022 \
    --boot-disk-size=100GB \
    --boot-disk-type=pd-ssd \
    --network=default \
    --metadata="install-nvidia-driver=True" \
    --metadata-from-file=windows-startup-script-ps1=setup/troubleshoot-controller.ps1 \
    --verbosity=info

echo "Instance creation command sent."
echo "The troubleshooting script will run automatically during boot."
echo "Please wait ~5-10 minutes for initialization."
echo "Once ready:"
echo "1. Run ./reset-debug-password.sh"
echo "2. Connect via RDP."
echo "3. Check C:\Temp\ControllerFix.log for results."
