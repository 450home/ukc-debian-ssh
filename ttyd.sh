#!/bin/sh
# webssh 网页终端启动脚本
# 网页访问 6080 端口即进终端(用户 root, 密码 unikraft)
set -e

export HOME=/root
export LANG=C.UTF-8

# webssh: 网页 SSH 终端, 监听 6080
exec wssh --port=6080 --host=0.0.0.0 --policy=reject --username=root --password=unikraft
