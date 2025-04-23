# Use a specific patch version of Node.js 22 LTS on Debian Slim for improved security
FROM node:22.14.0-slim

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json ./
RUN npm install --production

# Bundle app source
COPY server.js ./

# Expose port
EXPOSE 3000

# Health check for K8s probes
HEALTHCHECK --interval=30s --timeout=3s CMD wget --quiet --tries=1 --spider http://localhost:3000/healthz || exit 1

# Start the app
CMD ["npm", "start"]
