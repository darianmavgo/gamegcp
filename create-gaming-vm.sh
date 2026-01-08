#!/bin/bash
# Creates a new Windows Server 2022 instance for gaming troubleshooting.

INSTANCE_NAME="win-gaming-debug"
ZONE="us-east1-d"
# Dynamically get the current project ID
PROJECT_ID=$(gcloud config get-value project)

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Could not determine Project ID. Please set it using 'gcloud config set project <PROJECT_ID>'."
    exit 1
fi

echo "Creating instance $INSTANCE_NAME in $ZONE for Project: $PROJECT_ID..."

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
    --verbosity=info

echo "Instance creation command sent."
echo "Please wait for the instance to initialize."
echo "Once running, reset the password using ./reset-debug-password.sh"
echo "Then follow the instructions in CONTROLLER_DEBUG.md"
