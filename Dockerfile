FROM node:22-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package.json package-lock.json* ./
RUN \
  if [ -f package-lock.json ]; then npm ci; \
  fi

COPY .env .env
RUN npm run build

FROM base AS builder
WORKDIR /app
RUN npm install
COPY . .

COPY .env .env
RUN npm run build

FROM base AS runner

ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs \
  && adduser -S arandu -u 1001

COPY --from=builder --chown=arandu:nodejs /app/node_modules ./node_modules

USER arandu

EXPOSE 3000

ENV PORT=3000

CMD ["npm", "run", "start:prod"]
