# Use official Node.js 18 image (slim version)
FROM node:18-slim

# Set working directory
WORKDIR /app

# Copy files and install dependencies
COPY package*.json ./
RUN npm install

# Copy rest of the app
COPY . .

# Expose app port and run
EXPOSE 3000
CMD ["npm", "start"]
