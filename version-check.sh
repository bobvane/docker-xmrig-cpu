#!/bin/bash

# 获取当前使用的版本
CURRENT=$(docker inspect xmrig-cpu:latest --format '{{ index .Config.Labels "org.opencontainers.image.version" }}')

# 获取GitHub最新版本
LATEST=$(curl -sSL https://api.github.com/repos/xmrig/xmrig/releases/latest | jq -r '.tag_name | ltrimstr("v")')

# 版本比对
if [ "$CURRENT" != "$LATEST" ]; then
  echo "发现新版本: $LATEST (当前使用: $CURRENT)"
  ./build.sh
else
  echo "当前已是最新版本: $CURRENT"
fi
