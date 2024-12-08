# Build stage
FROM node:23.3.0-slim AS builder

# Install Python and build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
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
FROM node:23.3.0-slim

# Install Python in production image
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
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