# Use Node.js 23.3.0 as the base image
FROM node:23.3.0-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install pnpm and pm2
RUN npm install -g pnpm@latest pm2@latest

# Set working directory
WORKDIR /app

# Clone ElizaOS repository (shallow clone to save memory)
RUN git clone --depth 1 https://github.com/elizaOS/eliza.git . \
    && rm -rf .git

# Copy configuration files
COPY .env.docker .env

# Set build optimization flags
ENV NODE_OPTIONS="--max-old-space-size=2048"
ENV PNPM_SKIP_PRUNING="true"
ENV NODE_MODULES_CACHE="false"
ENV PORT=8080
ENV CLIENT_PORT=3000
ENV NODE_ENV="development"

# Install all dependencies first
RUN pnpm install --no-frozen-lockfile --shamefully-hoist

# Build core package and generate docs
RUN cd packages/core && \
    pnpm build && \
    pnpm typedoc --out ./docs src/index.ts && \
    cd ../..

# Build documentation
RUN cd docs && \
    mkdir -p docs/api && \
    cp -r ../packages/core/docs/* docs/api/ && \
    pnpm build && \
    cd ..

# Clean up and install production dependencies
RUN rm -rf node_modules/.vite tests docs \
    && pnpm store prune \
    && pnpm install --prod --no-frozen-lockfile --shamefully-hoist

# Create PM2 process file with memory limits
RUN echo '{\
    "apps": [\
    {\
    "name": "server",\
    "script": "pnpm",\
    "args": "start",\
    "env": {\
    "PORT": "8080",\
    "HOST": "0.0.0.0",\
    "NODE_ENV": "development"\
    },\
    "max_memory_restart": "1G"\
    },\
    {\
    "name": "client",\
    "script": "pnpm",\
    "args": "start:client",\
    "env": {\
    "PORT": "3000",\
    "HOST": "0.0.0.0",\
    "NODE_ENV": "development"\
    },\
    "max_memory_restart": "1G"\
    }\
    ]\
    }' > ecosystem.config.json

# Expose ports for health checks and web client
EXPOSE 8080
EXPOSE 3000

# Start the application using PM2 in no-daemon mode
CMD ["pm2-runtime", "start", "ecosystem.config.json"] 