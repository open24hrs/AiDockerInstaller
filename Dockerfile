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

# Set build optimization flags
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV PNPM_SKIP_PRUNING="true"
ENV NODE_MODULES_CACHE="false"

# Install dependencies and build with optimizations (following DO's recommended pattern)
RUN pnpm install --production=false \
    && pnpm build \
    && rm -rf node_modules \
    && pnpm install --production --frozen-lockfile \
    && rm -rf .git tests docs

# Expose ports for web client
EXPOSE 3000
EXPOSE 8000

# Start the application
CMD ["sh", "-c", "pnpm start & pnpm start:client"] 