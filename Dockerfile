# Use lightweight Node.js runtime
FROM node:18-alpine

# Set working directory in the container
WORKDIR /app

LABEL maintainer="qzee"

RUN addgroup -S appuser && adduser -S appuser -G appuser

# Copy the built artifact from CI (all files ready to run)
COPY --chown=appuser:appuser . .


# Expose the port your app listens on
EXPOSE 3000

USER appuser
# Command to start the app
CMD ["node", "app.js"]

