FROM oven/bun:1.2.22-alpine

WORKDIR /app

COPY package.json bun.lock ./

RUN bun install

COPY . .

EXPOSE 4000

CMD ["sh","-c","bunx prisma generate && bun run dev"]