FROM node:20-alpine as builder
WORKDIR /usr/local/app
COPY . .
RUN npm install
ARG API_URL
RUN VITE_API_URL=${API_URL} npm run build

FROM nginx:1.25-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /usr/local/app/dist .
CMD ["nginx", "-g", "daemon off;"]
