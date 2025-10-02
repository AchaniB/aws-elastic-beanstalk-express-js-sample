FROM node:18-slim

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io && \
    apt-get clean

# Optional: verify
RUN docker --version

