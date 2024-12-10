# Build stage
FROM node:23-slim AS builder

# Install essential build dependencies in a single RUN command with proper cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /var/lib/apt/lists/lock && \
    rm -f /var/cache/apt/archives/lock && \
    rm -f /var/lib/dpkg/lock*

# Install pnpm globally
RUN npm install -g pnpm

WORKDIR /app

# Copy package files
COPY package.json tsconfig.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code and build
COPY src ./src
COPY characters ./characters
COPY .env ./
RUN ./node_modules/.bin/tsc

# Production stage
FROM node:23-slim

# Install runtime dependencies and Playwright dependencies in a single step
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /var/lib/apt/lists/lock && \
    rm -f /var/cache/apt/archives/lock && \
    rm -f /var/lib/dpkg/lock* && \
    npm install -g pnpm playwright && \
    playwright install --with-deps chromium

WORKDIR /app

# Copy package files and install dependencies
COPY package.json pnpm-lock.yaml tsconfig.json ./
RUN pnpm install --frozen-lockfile --prod

# Copy built files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/characters ./characters
COPY --from=builder /app/.env ./

EXPOSE 3000

CMD ["tail", "-f", "/dev/null"]