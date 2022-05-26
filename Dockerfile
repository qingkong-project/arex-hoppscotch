FROM node:lts-alpine

# Create app directory
WORKDIR /app

ADD . /app/

COPY . .

RUN npm install -g pnpm --registry http://registry.npm.release.ctripcorp.com

RUN pnpm i --unsafe-perm=true --registry http://registry.npm.release.ctripcorp.com

ENV HOST 0.0.0.0
EXPOSE 3000

RUN mv packages/hoppscotch-app/.env.example packages/hoppscotch-app/.env

RUN pnpm run generate

CMD ["pnpm", "run", "start"]
