#!/bin/sh
# ttyd 网页终端启动脚本
# 网页访问 6080 端口即进终端(用户 root, 密码 unikraft)
set -e

export HOME=/root
export LANG=C.UTF-8

# ttyd 网页终端, 带基本认证
exec ttyd -p 6080 -c "root:unikraft" login
