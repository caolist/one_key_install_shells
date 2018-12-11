#!/bin/bash
if [[ $# < 1 ]] ; then
    echo "Usage: $0 1.hadoop_home"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 配置环境变量
echo "export HADOOP_HOME=$1
export PATH=$PATH:$1/bin:$1/sbin
export HADOOP_COMMON_LIB_NATIVE_DIR=$1/lib/native
export HADOOP_OPTS="-Djava.library.path=$1/lib"
export HADOOP_CONF_DIR=$1/etc/hadoop
export YARN_HOME=$1
export YARN_CONF_DIR=$1/etc/hadoop" >> /etc/profile
source /etc/profile

# 创建数据存放的文件夹
mkdir -p $1/tmp
mkdir -p $1/var
mkdir -p $1/hdfs
mkdir -p $1/hdfs/data
mkdir -p $1/hdfs/name