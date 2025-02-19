# ElizaOS Basic Web Client

This is a minimal setup of ElizaOS focusing on the web client chat functionality.

## Requirements

- Node.js v23.3.0
- pnpm package manager

## Deployment on DigitalOcean App Platform

1. Fork this repository to your GitHub account
2. Log in to your DigitalOcean account
3. Go to the App Platform section
4. Click "Create App"
5. Select your GitHub repository
6. Choose "Dockerfile" as the deployment method
7. Configure the following environment variables in DO App Platform:
   - `PORT`: 3000
   - `CLIENT_PORT`: 8000
   - `NODE_ENV`: production
   - `ENABLE_PLUGINS`: false
   - `ENABLE_EXTENSIONS`: false
   - Update `VITE_API_URL` and `VITE_WS_URL` with your app's URL once deployed

## Local Development

```bash
# Install dependencies
pnpm install

# Build the application
pnpm build

# Start the application
pnpm start & pnpm start:client
```

The web client will be available at `http://localhost:8000` 