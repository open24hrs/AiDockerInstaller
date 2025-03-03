# Use Node.js 23.3.0 as the base image
FROM node:23.3.0-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm and pm2
RUN npm install -g pnpm@latest pm2@latest

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
ENV PORT=8080
ENV CLIENT_PORT=3000

# Install dependencies and build with optimizations (following DO's recommended pattern)
RUN pnpm install --production=false --no-frozen-lockfile \
    && pnpm build \
    && rm -rf node_modules \
    && pnpm install --production --no-frozen-lockfile \
    && rm -rf .git tests docs

# Create PM2 process file
RUN echo '{\
    "apps": [\
    {\
    "name": "server",\
    "script": "pnpm",\
    "args": "start",\
    "env": {\
    "PORT": "8080",\
    "HOST": "0.0.0.0"\
    }\
    },\
    {\
    "name": "client",\
    "script": "pnpm",\
    "args": "start:client",\
    "env": {\
    "PORT": "3000",\
    "HOST": "0.0.0.0"\
    }\
    }\
    ]\
    }' > ecosystem.config.json

# Expose ports for health checks and web client
EXPOSE 8080
EXPOSE 3000

# Start the application using PM2 in no-daemon mode
CMD ["pm2-runtime", "start", "ecosystem.config.json"] 