#!/bin/bash
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.flink_home"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 配置环境变量
export FLINK_HOME=/opt/module/$1
export PATH=$PATH:$FLINK_HOME/bin
source /etc/profile