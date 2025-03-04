#!/bin/bash

# 自动获取最新版本号
LATEST_VERSION=$(curl -sSL https://api.github.com/repos/xmrig/xmrig/releases/latest | jq -r '.tag_name | ltrimstr("v")')

# 构建Docker镜像（带动态标签）
docker build -t xmrig-cpu:${LATEST_VERSION} -t xmrig-cpu:latest . 

# 显示构建结果
echo "========================================"
echo " 成功构建以下版本:"
echo " - 最新稳定版: xmrig-cpu:${LATEST_VERSION}"
echo " - 浮动标签: xmrig-cpu:latest"
echo "========================================"

# 可选：自动推送到镜像仓库
# docker push xmrig-cpu:${LATEST_VERSION}
# docker push xmrig-cpu:latest
