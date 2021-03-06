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
echo "export FLINK_HOME=$1
export PATH=$PATH:$1/bin" >> /etc/profile
source /etc/profile