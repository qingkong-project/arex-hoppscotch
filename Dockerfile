FROM node:lts-alpine

# Create app directory
WORKDIR /app

ADD . /app/

COPY . .

RUN npm install -g pnpm --registry=https://registry.npm.taobao.org

RUN pnpm i --unsafe-perm=true --registry=https://registry.npm.taobao.org

ENV HOST 0.0.0.0
EXPOSE 3000

RUN mv packages/hoppscotch-app/.env.example packages/hoppscotch-app/.env

RUN pnpm run generate

CMD ["pnpm", "run", "start"]
