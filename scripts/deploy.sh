#!/usr/bin/env sh

# Check if DEPLOY_IP variable is set
if [ -z "$DEPLOY_IP" ]; then
    echo "Error: DEPLOY_IP variable is not set. Please set DEPLOY_IP before running this script."
    exit 1
fi

# Check if DEPLOY_USER variable is set
if [ -z "$DEPLOY_USER" ]; then
    echo "Error: DEPLOY_USER variable is not set. Please set DEPLOY_USER before running this script."
    exit 1
fi

# Build Docker image
docker build -t task-manager . || exit 1

# Save Docker image as a tar file
docker save -o task-manager.tar task-manager || exit 1

# Create deploy directory
ssh "$DEPLOY_USER@$DEPLOY_IP" 'mkdir -p ~/homelab/task-manager' || exit 1

# Copy the tar file to the deployment server using scp
scp task-manager.tar "$DEPLOY_USER@$DEPLOY_IP:~/homelab/task-manager" || exit 1

# Copy the docker compose file to the deployment server using scp
scp ./scripts/docker-compose.yml "$DEPLOY_USER@$DEPLOY_IP:~/homelab/task-manager" || exit 1

# SSH into the server
ssh "$DEPLOY_USER@$DEPLOY_IP" << EOF
    # Load Docker image from the tar file
    cd homelab/task-manager
    docker load -i task-manager.tar

    # Create database file if it does not exist
    touch task-manager.db
    chmod 666 task-manager.db

    # Restart Docker Compose service with the new image
    docker compose down
    docker compose up -d
EOF

# Clean up: remove the local tar file
rm task-manager.tar || exit 1

echo "Docker image has been built and deployed to $DEPLOY_IP"
