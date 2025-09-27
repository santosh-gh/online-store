# Uses a lightweight Node.js 22 image (based on Alpine Linux).
# Labeled as builder for later reference.
FROM node:22.14-alpine AS builder

# Sets the working directory inside the container to /app.
WORKDIR /app

# Copy only package.json and package-lock.json to the container
# This is a common optimization so npm install can use Docker’s cache when source code changes but dependencies do not.
COPY package*.json ./

# Installs dependencies from package.json.
RUN npm install

# Copies the rest of the application source code into /app.
COPY . .

# Build the app
RUN npm run build 

# Run the app on nginx
# Uses a small, stable Nginx image to serve the built files.
# Named as runner.
FROM nginx:stable-alpine-slim AS runner

# Copy the build output to replace the default nginx contents
# Copies the compiled app (static files from /app/dist) into Nginx’s default serving directory.
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose the port the app listens on
# Declares that the container listens on port 8080.
EXPOSE 8080

# Defines a build-time argument (ARG) for the app version, defaulting to 0.1.0.
ARG APP_VERSION=0.1.0

# Sets it as an environment variable (ENV) inside the container, so Nginx config (or other processes) can reference it.
ENV APP_VERSION=$APP_VERSION

# Copies a template Nginx configuration file into the container.
# The .template suffix suggests it contains placeholders (e.g., ${APP_VERSION}).
COPY nginx.conf /etc/nginx/conf.d/nginx.conf.template

# Uses envsubst to replace the ${APP_VERSION} placeholder in the template with the actual environment variable value.
# Outputs the final config as default.conf, which Nginx uses.

RUN envsubst '${APP_VERSION}' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/default.conf

# Starts Nginx in the foreground (the container’s main process).
CMD ["nginx", "-g", "daemon off;"]