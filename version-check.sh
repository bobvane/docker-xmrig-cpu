#!/bin/bash

# 安全配置：遇到错误立即终止
set -eo pipefail

# 获取本地当前版本
CURRENT_VERSION=$(docker inspect --format '{{ index .Config.Labels "org.opencontainers.image.version" }}' xmrig-cpu:latest 2>/dev/null || echo "none")

# 获取远程最新版本
LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/xmrig/xmrig/releases/latest | \
  jq -r '.tag_name | sub("^v"; "")')

# 版本比对
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo -e "\033[33m⚠️ 发现新版本: ${LATEST_VERSION} (当前: ${CURRENT_VERSION})\033[0m"
  ./build.sh
else
  echo -e "\033[32m✓ 当前已是最新版本: ${CURRENT_VERSION}\033[0m"
fi
