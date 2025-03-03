# Use Node.js 23.3.0 as the base image
FROM node:23.3.0-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@latest

# Set working directory
WORKDIR /app

# Clone ElizaOS repository
RUN git clone https://github.com/elizaOS/eliza.git .

# Copy configuration files
COPY .env.docker .env

# Set memory and build optimization flags
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV NODE_ENV="production"
ENV PNPM_FLAGS="--production=false --network-concurrency 1 --network-timeout 100000"

# Install dependencies and build with optimizations (following DO's recommended pattern)
RUN pnpm install $PNPM_FLAGS \
    && pnpm build \
    && rm -rf node_modules \
    && pnpm install --production --frozen-lockfile \
    && rm -rf .git tests docs \
    && pnpm store prune \
    && pnpm cache clean --force

# Expose ports for web client
EXPOSE 3000
EXPOSE 8000

# Start the application
CMD ["sh", "-c", "pnpm start & pnpm start:client"] 