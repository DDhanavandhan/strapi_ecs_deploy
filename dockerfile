#Use Node.js official image
FROM node:20-alpine

# Install necessary packages using apk
RUN apk add --no-cache \
  build-base \
  python3 \
  make \
  g++ \
  sqlite \
  sqlite-dev \
  git

#Set working directory
WORKDIR /app

#Copy package files and install dependencies

COPY package.json package-lock.json ./

COPY .env .env

RUN npm install

#Copy the entire Strapi app source code

COPY . .

#Build the Strapi admin panel

RUN npm run build

# Rebuild native modules for architecture compatibility
RUN npm rebuild better-sqlite3

# Set proper permissions
RUN chown -R node:node /app
USER node

#Expose Strapi port

EXPOSE 1337

# Default command to run Strapi

CMD ["npm", "run", "start"]