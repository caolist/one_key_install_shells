#/bin/sh
# created by caoli 2018/12/03
# -----------------------------------------------------------------------------
# shell script for installing spark (version 2.7.7)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ;
then
    echo "请使用 root 用户执行!"
    exit
fi

#check the java home
if [ "$JAVA_HOME" = "" ]
then
    echo "JAVA_HOME IS EMPTY"
    exit 1
fi

# 设置调试模式
# set -x

# 脚本参数解析
if [[ $# < 3 ]] ; then
    echo "Usage: $0 1.spark node config file path(file content format as follows:) 2.spark version 3.scala version"
    echo "example:"
    echo "./spark_install.sh spark_config 2.3.0-bin-hadoop2.7 2.11.12"
    echo "1.host_name 2.hadoop_home 3.scala_home"
    echo "example:"
    echo "node01 /opt/spark /opt/scala"
    echo "node02 /opt/spark /opt/scala"
    echo "node03 /opt/spark /opt/scala"
    exit
fi

echo "-----------------------开始安装 spark----------------------"

# 安装 scala
scala_version=$3
echo $scala_version

# 解压安装 scala
tar -xzf scala-${scala_version}.tar.gz

# 安装 spark
spark_version=$2
echo $spark_version

# 解压安装 spark
ar -xzf spark-${spark_version}.tar.gz

# 删除 slaves 配置文件中默认内容
sed -i '19,$d' spark-${spark_version}/conf/slaves.template
cp spark-${spark_version}/conf/slaves.template spark-${spark_version}/conf/slaves

# 修改解压文件中的配置文件内容
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 spark 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    is_master=`echo ${line} | awk '{print $4}'`
    
    if [[ $is_master = "false" ]] ; then
        echo ${host_name} >> spark-${spark_version}/conf/slaves
    else
        master=${host_name}
    fi
    
done

sed -i '70,$d' spark-${spark_version}/conf/spark-env.sh.template
cp spark-${spark_version}/conf/spark-env.sh.template spark-${spark_version}/conf/spark-env.sh
echo "export SCALA_HOME=$SCALA_HOME
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop">>spark-${spark_version}/conf/spark-env.sh

# cp spark-${spark_version}/conf/spark-defaults.conf.template spark-${spark_version}/conf/spark-defaults.conf
# echo "
# ">>spark-${spark_version}/conf/spark-env.sh

# 根据配置文件进行操作
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 spark 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    spark_home=`echo ${line} | awk '{print $2}'`
    scala_home=`echo ${line} | awk '{print $3}'`
    
    echo "$host_name 节点安装 spark..."
    ssh -t root@${host_name} << EOF
mkdir -p $scala_home
mkdir -p $spark_home
EOF
    
    scp -r -q scala-${scala_version}/* $host_name:$scala_home
    scp -r -q spark-${spark_version}/* $host_name:$hadoop_home
    
    # 拷贝环境配置脚本以及启动脚本
    scp -q spark_install_config.sh $host_name:/opt/spark_install_config.sh
    
    echo "-----------------------配置 spark----------------------"
    ssh -t root@${host_name} << EOF
sh /opt/spark_install_config.sh $spark_home $scala_home
rm -rf /opt/spark_install_config.sh
EOF
done

# echo "-----------------------启动 spark----------------------"
# # 修改解压文件中的配置文件内容
# cat $1 | while read line || [ -n "$line" ]
# do
    
#     # 读取 spark 配置文件参数值
#     host_name=`echo ${line} | awk '{print $1}'`
#     spark_home=`echo ${line} | awk '{print $2}'`
#     is_master=`echo ${line} | awk '{print $3}'`
    
#     if [[ $is_master = "true" ]] ; then
#         ssh -t root@${host_name} << EOF
# sh $spark_home/sbin/start-all.sh
# EOF
#     fi
# done

# 删除 spark 安装文件
rm -rf scala-${scala_version}
rm -rf spark-${spark_version}

echo "-----------------------完成安装 spark----------------------"