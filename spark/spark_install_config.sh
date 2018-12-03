#!/bin/bash
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.spark_home 2.scala_home"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 配置环境变量
export SCALA_HOME==$2
export PATH=$PATH:$SCALA_HOME/bin
export SPARK_HOME=$1
export PATH=.:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
source /etc/profile