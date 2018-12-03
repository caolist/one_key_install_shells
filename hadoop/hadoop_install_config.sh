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
export HADOOP_HOME=$1
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_HOME=$1
export YARN_CONF_DIR=$YARN_HOME/etc/hadoop
source /etc/profile

# 创建数据存放的文件夹
mkdir $1/tmp
mkdir $1/hdfs
mkdir hdfs/data
mkdir hdfs/name