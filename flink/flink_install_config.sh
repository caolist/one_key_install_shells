#!/bin/bash
if [[ $# < 1 ]] ; then
    echo "Usage: $0 1.flink_home"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 配置环境变量
echo "export FLINK_HOME=/opt/module/$1
export PATH=$PATH:$FLINK_HOME/bin" >> /etc/profile
source /etc/profile