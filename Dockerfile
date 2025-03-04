# Build stage
FROM node:23.3.0-slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install pnpm
RUN npm install -g pnpm@latest

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-workspace.yaml ./
COPY packages/core/package.json ./packages/core/
COPY packages/adapter-sqlite/package.json ./packages/adapter-sqlite/
COPY packages/adapter-sqljs/package.json ./packages/adapter-sqljs/
COPY packages/adapter-supabase/package.json ./packages/adapter-supabase/
COPY packages/adapter-pglite/package.json ./packages/adapter-pglite/

# Install dependencies (without frozen-lockfile since we don't have pnpm-lock.yaml)
RUN pnpm install

# Copy source files
COPY . .

# Build application
RUN pnpm build

# Production stage
FROM node:23.3.0-slim

# Install pnpm
RUN npm install -g pnpm@latest

WORKDIR /app

# Copy built files and dependencies
COPY --from=builder /app/package.json /app/pnpm-workspace.yaml ./
COPY --from=builder /app/packages/core/package.json ./packages/core/
COPY --from=builder /app/packages/core/dist ./packages/core/dist
COPY --from=builder /app/packages/adapter-*/dist ./packages/adapter-*/dist
COPY --from=builder /app/packages/adapter-*/package.json ./packages/adapter-*/
COPY --from=builder /app/pnpm-lock.yaml ./

# Install production dependencies only
RUN pnpm install --prod

# Set environment variables
ENV PORT=8080
ENV CLIENT_PORT=3000
ENV NODE_ENV=production
ENV ENABLE_PLUGINS=false
ENV ENABLE_EXTENSIONS=false

# Expose the port
EXPOSE 8080
EXPOSE 3000

# Start the application
CMD ["pnpm", "start"] 