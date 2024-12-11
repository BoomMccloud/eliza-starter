# Build stage
FROM node:23-slim

# Install system dependencies all at once
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    build-essential && \
    rm -rf /var/lib/apt/lists/* 

# Install pnpm 
RUN npm install -g pnpm 

WORKDIR /app

# Copy package files and install dependencies
COPY package.json tsconfig.json pnpm-lock.yaml ./

RUN pnpm install --ignore-scripts && \
    pnpm rebuild

# Install browser with explicit home directory setting
ENV PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright

RUN mkdir -p /root/.cache/ms-playwright && \
    npx playwright@1.48.2 install --with-deps chromium && \
    npx playwright@1.48.2 install-deps chromium
    # Verify installation paths
    # ls -la /root/.cache/ms-playwright/chromium-1140/chrome-linux/chrome

# Copy source code and build
COPY src ./src
COPY characters ./characters
COPY .env ./

# Build TypeScript
RUN ./node_modules/.bin/tsc

EXPOSE 3000

CMD ["tail", "-f", "/dev/null"]