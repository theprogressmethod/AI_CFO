# Use Node.js LTS
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (including dev dependencies for build)
RUN npm install

# Copy all source files
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm install --production

# Copy built application from builder stage
COPY --from=builder /app/build ./build

# Copy static files if any
COPY --from=builder /app/static ./static 2>/dev/null || true

# Expose port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0
ENV ORIGIN=https://financial-processor.onrender.com

# Start the application
CMD ["node", "build"]