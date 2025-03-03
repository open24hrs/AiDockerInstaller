# Use Node.js 23.3.0 as the base image
FROM node:23.3.0-slim

# Install system dependencies and setup swap space
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && fallocate -l 4G /swapfile \
    && chmod 600 /swapfile \
    && mkswap /swapfile \
    && swapon /swapfile \
    && echo '/swapfile none swap sw 0 0' >> /etc/fstab \
    && echo 'vm.swappiness=80' >> /etc/sysctl.conf \
    && sysctl -p

# Install pnpm
RUN npm install -g pnpm@latest

# Set working directory
WORKDIR /app

# Clone ElizaOS repository
RUN git clone https://github.com/elizaOS/eliza.git .

# Copy configuration files
COPY .env.docker .env

# Set PNPM memory optimization flags
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV PNPM_FLAGS="--no-frozen-lockfile --network-concurrency 1 --network-timeout 100000"

# Install dependencies and build with optimizations
RUN pnpm install $PNPM_FLAGS \
    && pnpm build \
    && pnpm prune --prod \
    && rm -rf .git tests docs

# Verify swap is working
RUN free -h

# Expose ports for web client
EXPOSE 3000
EXPOSE 8000

# Start the application
CMD ["sh", "-c", "pnpm start & pnpm start:client"] 