#!/bin/bash

# 异常中断处理
set -eo pipefail

# 获取最新正式版版本号（跳过预发布版本）
LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/xmrig/xmrig/releases/latest | \
  jq -r '.tag_name | sub("^v"; "")')

# 构建镜像并打双标签
docker build -t "xmrig-cpu:${LATEST_VERSION}" -t xmrig-cpu:latest .

# 构建结果输出
echo -e "\n\033[32m✔ 成功构建以下镜像标签:\033[0m"
echo -e " - \033[34mxmrig-cpu:${LATEST_VERSION}\033[0m (版本锁定)"
echo -e " - \033[34mxmrig-cpu:latest\033[0m    (浮动标签)\n"

# 提示推送命令
echo "如需发布到镜像仓库，请执行:"
echo "  docker push xmrig-cpu:${LATEST_VERSION}"
echo "  docker push xmrig-cpu:latest"
