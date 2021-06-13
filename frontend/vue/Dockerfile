### STAGE 1: Build ###
FROM node:16.2-slim as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY ./ .
ARG NODE_ENV=docker
RUN npm run build -- --mode $NODE_ENV

### STAGE 2: web server setup ###
FROM nginx:1.20.0 as production-stage

LABEL maintainer="romitagl@gmail.com"

RUN mkdir /app
COPY --from=build-stage /app/dist /app
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

### OTHER OPTION TO SERVER ###
# FROM node:carbon

# # Create app directory
# WORKDIR /app

# # Install app dependencies
# RUN npm -g install serve
# # A wildcard is used to ensure both package.json AND package-lock.json are copied
# COPY package*.json ./

# RUN npm ci

# # Bundle app source
# COPY . /app
# #Build react/vue/angular bundle static files
# RUN npm run build

# EXPOSE 8080
# # serve dist folder on port 8080
# CMD ["serve", "-s", "dist", "-p", "8080"]