FROM node:23.3.0
# Install pnpm globally
RUN npm install -g pnpm

# Set the working directory
WORKDIR /app

# Add configuration files and install dependencies

ADD package.json /app/package.json
ADD tsconfig.json /app/tsconfig.json
ADD pnpm-lock.yaml /app/pnpm-lock.yaml
ADD .env /app/.env

ADD src /app/docs
ADD characters /app/characters
RUN pnpm update
RUN pnpm i

# Command to run the container
CMD ["pnpm", "start", "--characters='./characters/eliza.character.json'"]