gcloud compute firewall-rules create allow-parsec-udp \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=udp:8000-8010 \
    --source-ranges=0.0.0.0/0 \
    --network=default \
    --priority=1000 \
    --description="Allow inbound UDP for Parsec hosting (8000-8010)" \
    --target-tags=parsec-host