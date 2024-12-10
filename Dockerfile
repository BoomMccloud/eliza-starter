# Build stage
FROM node:22-slim AS builder

# Install Python and build dependencies with apt lock handling
RUN while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do \
    echo "Waiting for apt lock release..." && \
    sleep 1; \
    done && \
    apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    # Playwright dependencies
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxcb1 \
    libxkbcommon0 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm

# Set the working directory
WORKDIR /app

# Copy package files
COPY package.json tsconfig.json pnpm-lock.yaml ./

# Install all dependencies (including devDependencies)
RUN pnpm install

# Copy source code
COPY src ./src
COPY characters ./characters
COPY .env ./

# Build TypeScript files using local tsc
RUN ./node_modules/.bin/tsc

# Production stage
FROM node:22-slim

# Install Python and Playwright dependencies in production image
RUN while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do \
    echo "Waiting for apt lock release..." && \
    sleep 1; \
    done && \
    apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    # Playwright dependencies
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxcb1 \
    libxkbcommon0 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm

WORKDIR /app

# Copy package files and tsconfig.json
COPY package.json pnpm-lock.yaml tsconfig.json ./

# Install all dependencies (not --prod since we need ts-node)
RUN pnpm install

# Copy built files from builder stage
COPY --from=builder /app/src ./src
COPY --from=builder /app/characters ./characters
COPY --from=builder /app/.env ./
COPY --from=builder /app/dist ./dist

EXPOSE 3000

# CMD ["pnpm", "start", "--characters=./characters/eliza.character.json"]
CMD ["tail", "-f", "/dev/null"]