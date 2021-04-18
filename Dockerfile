# Multi-stage
# 1) Node image for building frontend assets
# 2) nginx stage to serve frontend assets

# Name the node stage "builder"
FROM node:10 AS builder

# Set working directory
WORKDIR /app

# Copy all files from current directory to working dir in image
COPY . .

# install node modules and build assets
RUN npm install && npm run build

# nginx state for serving content
FROM nginx:1.18

## Copy our default nginx config
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## Copy over the artifacts in build folder to default nginx public folder
COPY --from=builder /app/build /usr/share/nginx/html/

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]