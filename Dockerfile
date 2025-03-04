# 使用官方Ubuntu 22.04作为基础镜像
FROM ubuntu:22.04

# 设置容器时区（避免日志时间混乱）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装基础依赖（比原配置更完整的依赖项）
RUN apt update && \
    apt install -y \
    wget \            # 文件下载工具
    libssl3 \         # SSL加密库（xmrig必需）
    libhwloc15 \      # 硬件定位库（CPU拓扑检测）
    && rm -rf /var/lib/apt/lists/*  # 清理缓存减小镜像体积

# 下载并安装XMRig（优化解压流程）
RUN wget https://github.com/xmrig/xmrig/releases/download/v6.20.0/xmrig-6.20.0-linux-static-x64.tar.gz -O /tmp/xmrig.tar.gz && \
    tar -zxvf /tmp/xmrig.tar.gz -C /usr/local/src/ && \      # 解压到临时目录
    cp /usr/local/src/xmrig-*/xmrig /usr/local/bin/xmrig && \ # 复制可执行文件
    rm -rf /tmp/xmrig.tar.gz /usr/local/src/xmrig-*  # 清理安装残留

# 复制配置文件（需与Dockerfile同级目录存在config.json）
COPY config.json /etc/xmrig/config.json

# 创建专用运行用户（安全加固）
RUN useradd -m -u 1000 -s /bin/bash xmrig-user && \
    chown -R xmrig-user:xmrig-user /etc/xmrig

# 切换运行用户（禁止root运行）
USER xmrig-user

# 容器启动命令（优先级：命令行参数 > 环境变量 > 配置文件）
CMD ["xmrig", \
    "--config=/etc/xmrig/config.json", \   # 主配置文件路径
    "--donate-level=1", \                 # 强制设置捐赠等级
    "-o", "$POOL", \                      # 环境变量传入矿池地址（覆盖配置）
    "-u", "$WALLET" \                     # 环境变量传入钱包地址（覆盖配置）
]
