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
echo 'export SCALA_HOME='$2'' >> /etc/profile
echo 'export PATH=$PATH:$SCALA_HOME/bin' >> /etc/profile
echo 'export SPARK_HOME='$1'' >> /etc/profile
echo 'export PATH=.:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH' >> /etc/profile
source /etc/profile

# 修改配置文件
echo "export SCALA_HOME=$2
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> $1/conf/spark-env.sh