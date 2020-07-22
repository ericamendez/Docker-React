#  multi step process
# build phase
FROM node:alpine as builder
WORKDIR '/app'
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

#  run phase
# /app/build <- will have all the things we care about which is just the static files, we will not copy over anything else from build phase
FROM nginx

#  Just for production. EBS will look for this opt ion and whaterver port you specify EBS will map automatically
EXPOSE 80

# we want to copy something from a different phase
COPY --from=builder /app/build /usr/share/nginx/html