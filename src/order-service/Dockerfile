# Use an official Node.js runtime as a parent image
# It’s based on Alpine Linux, which is a very lightweight Linux distribution (small image size, faster to pull, less attack surface).
# The alias AS builder names this stage “builder,” which is useful if you want to do multi-stage builds.

FROM node:18.20.5-alpine AS builder

# Sets the working directory inside the container to /app.
# All following commands (COPY, RUN, etc.) are executed relative to this directory.
# If /app doesn’t exist, Docker will create it automatically.

WORKDIR /app

# Set the build argument for the app version number
# Default value is 0.1.0, but you can override it at build time with the --build-arg flag.
# docker build --build-arg APP_VERSION=1.2.3 -t my-app .

ARG APP_VERSION=0.1.0

# Copies package.json and package-lock.json (the * expands both) into the container’s /app directory.
# This is done before copying all source code to leverage Docker’s layer caching
# If your dependencies don’t change, Docker can reuse the cached npm install layer and skip re-installing packages.

COPY package*.json ./

# Installs only the production dependencies (ignores devDependencies).
# This makes the image lighter and reduces attack surface since dev tools aren’t included.
# Runs inside the container, so the installed node_modules will live inside /app/node_modules.

RUN npm install --production

# Copies all remaining source code from your project directory on the host into the container’s /app directory.
# Since we already copied package.json earlier, this step only adds source files, configs, assets, etc.

COPY . .

# Declares that the application inside the container will listen on port 3000.
EXPOSE 3000

# Persists the build-time ARG APP_VERSION into an environment variable that exists when the container runs.
# This way, your app can read the version at runtime via process.env.APP_VERSION.

ENV APP_VERSION=$APP_VERSION

# Defines the default command that runs when a container starts.
# In this case, it executes npm start, which usually runs whatever you have defined in package.json under "start".
# You can override this at runtime with: docker run my-app npm run dev

CMD [ "npm", "start" ]