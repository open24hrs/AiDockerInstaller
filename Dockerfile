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

# Install dependencies and build
RUN pnpm install
RUN pnpm build

# Expose ports for web client
EXPOSE 3000
EXPOSE 8000

# Start the application
CMD ["sh", "-c", "pnpm start & pnpm start:client"] 