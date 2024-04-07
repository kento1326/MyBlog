# 依存パッケージのインストール
FROM node:16 as deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# build環境
FROM node:16 as builder
WORKDIR /app
COPY . . 
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build

FROM gcr.io/distroless/nodejs:16
WORKDIR /app
ENV NODE_ENV production
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nonroot:nonroot /app/dist ./dist
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
USER nonroot
EXPOSE 8080
CMD [ "npm", "start" ]
