# ========================================================
# 多阶段构建Dockerfile - XMRig矿工容器（自动获取最新版）
# ========================================================

# ------------ 第一阶段：版本检测与元数据准备 ------------
FROM alpine:3.18 as version_fetcher

# 安装临时工具（仅构建阶段使用）
RUN apk add --no-cache curl jq

# 获取最新正式版本号（过滤预发布版本）
ARG GITHUB_API="https://api.github.com/repos/xmrig/xmrig/releases/latest"
RUN curl -sSL $GITHUB_API | \
    jq -r '.tag_name | sub("^v"; "")' > /tmp/xmrig-version && \
    echo "检测到最新版本: $(cat /tmp/xmrig-version)"

# ------------ 第二阶段：正式构建阶段 ------------
FROM ubuntu:22.04

# 从构建阶段复制版本信息文件
COPY --from=version_fetcher /tmp/xmrig-version /etc/xmrig-version

# 设置容器元数据（符合OCI标准）
LABEL maintainer="your-email@example.com" \
      org.opencontainers.image.title="XMRig CPU Miner" \
      org.opencontainers.image.version=$(cat /etc/xmrig-version) \
      org.opencontainers.image.description="自动构建的最新版XMRig挖矿容器"

# 安装运行时依赖（最小化安装原则）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl3 \        # SSL加密库（网络通信必需）
    libhwloc15 \     # 硬件拓扑检测库（优化CPU使用）
    ca-certificates \# CA证书（HTTPS验证）
    wget && \        # 下载工具（用于获取XMRig）
    rm -rf /var/lib/apt/lists/*

# 动态构建XMRig（使用检测到的版本号）
ARG XMRIG_VERSION=$(cat /etc/xmrig-version)
RUN echo "正在安装 XMRig v${XMRIG_VERSION}" && \
    # 下载官方预编译包
    wget -q "https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/xmrig-${XMRIG_VERSION}-linux-static-x64.tar.gz" -O /tmp/xmrig.tar.gz && \
    # 解压并安装到系统路径
    tar -zxvf /tmp/xmrig.tar.gz -C /usr/local/bin --strip-components=1 && \
    # 清理临时文件
    rm -f /tmp/xmrig.tar.gz && \
    # 验证可执行文件
    xmrig --version

# 安全加固配置
RUN useradd -r -u 1000 -d /nonexistent -s /bin/false xmrig && \
    # 创建配置文件目录
    mkdir -p /etc/xmrig && \
    # 设置权限隔离
    chown -R xmrig:xmrig /etc/xmrig

# 复制预置配置文件（需预先准备）
COPY config.json /etc/xmrig/config.json

# 切换到非特权用户
USER xmrig

# 健康检查（每5分钟检测一次矿池连接）
HEALTHCHECK --interval=5m --timeout=30s \
    CMD xmrig --config=/etc/xmrig/config.json --dry-run

# 容器入口配置
ENTRYPOINT ["xmrig"]

# 默认启动参数（可通过docker run覆盖）
CMD [
    "--config=/etc/xmrig/config.json",  # 主配置文件
    "--donate-level=1",                # 开发者捐赠等级
    "--randomx-init=1",                # 初始化RandomX数据集
    "--nicehash"                       # 兼容NiceHash服务
]
