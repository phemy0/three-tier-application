# Stage 1: Build
FROM node:18-alpine AS build
WORKDIR /app

# Install build essentials only if native modules are required
RUN apk add --no-cache python3 make g++

# Copy dependency files first for caching
COPY package*.json ./

# Install dependencies exactly as defined in package-lock.json
RUN npm ci

# Copy source code
COPY . .

# If you have a build step (like transpiling or bundling), run it here
# RUN npm run build

# Stage 2: Runtime
FROM node:18-alpine
WORKDIR /app

LABEL maintainer="qzee"

# Create non-root user
RUN addgroup -S appuser && adduser -S appuser -G appuser

# Copy only built artifacts and production dependencies
COPY --chown=appuser:appuser --from=build /app ./

# Expose the port your app listens on
EXPOSE 3000

USER appuser

# Command to start the app
CMD ["node", "app.js"]

