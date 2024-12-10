# Build stage
FROM node:23-slim AS builder

# Install essential build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm

WORKDIR /app

# Copy package files
COPY package.json tsconfig.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install

# Copy source code and build
COPY src ./src
COPY characters ./characters
COPY .env ./
RUN ./node_modules/.bin/tsc

# Production stage
FROM node:23-slim

# Install runtime dependencies and Playwright dependencies in one step
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libglib2.0-0 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libx11-6 \
    libxcomposite1 \
    libxfixes3 \
    libgbm1 \
    libpango-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm and Playwright globally
RUN npm install -g pnpm playwright && \
    playwright install --with-deps chromium

WORKDIR /app

# Copy package files and install dependencies
COPY package.json pnpm-lock.yaml tsconfig.json ./
RUN pnpm install

# Copy built files from builder
COPY --from=builder /app/src ./src
COPY --from=builder /app/characters ./characters
COPY --from=builder /app/.env ./
COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["tail", "-f", "/dev/null"]