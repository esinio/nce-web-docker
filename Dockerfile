# ---------- 阶段 1: 拉取源码并构建 ----------
FROM node:alpine AS builder

# 安装 git 和 pnpm
RUN apk add --no-cache git && npm install -g pnpm

WORKDIR /app

# 从远程仓库拉取代码（浅克隆，只取最新一次提交，加快速度）
ARG REPO_URL=https://github.com/wxaiway/nce-web.git
RUN git clone --depth 1 ${REPO_URL} . && rm -rf .git

# 通过 PUBLIC_PATH 覆盖 vite 的 base（与你本地验证过的行为一致）
ARG PUBLIC_PATH=/
RUN PUBLIC_PATH=${PUBLIC_PATH} pnpm install --frozen-lockfile && PUBLIC_PATH=${PUBLIC_PATH} pnpm build

# ---------- 阶段 2: 运行 ----------
FROM nginx:1.27-alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
