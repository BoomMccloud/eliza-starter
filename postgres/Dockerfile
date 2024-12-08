# Use the official PostgreSQL image as base
FROM postgres:15

# Set environment variables
ENV POSTGRES_DB=mydb
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

# Copy SQL initialization scripts
# Using numbered prefixes to control execution order
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql
COPY seed.sql /docker-entrypoint-initdb.d/02-seed.sql

# Install the required PostgreSQL extensions
RUN apt-get update \
    && apt-get install -y \
    postgresql-15-pgvector \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Expose PostgreSQL port
EXPOSE 5432

# The official image already includes CMD ["postgres"]