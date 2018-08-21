#/bin/sh
# created by caoli 2018/08/15
# -----------------------------------------------------------------------------
# shell script for install kafka-logs
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
set -x

# 脚本参数解析
if [[ $# < 3 ]] ; then
    echo "Usage: $0 1.kafka-logs config file path 2.elastic config file path 3.mysql config file path(file content format as follows:)"
    echo "example:"
    echo "./kafka-logs_install.sh kafka-logs_config elastic_config mysql_config"
    exit
fi

echo "-----------------------开始安装 kafka-logs----------------------"

# 判断集群是否安装 kafka
if [[ ! -e /opt/kafka ]] ; then
    echo "集群没有安装 kafka!"
    exit
fi

while read line || [ -n "$line" ]
do
    host_name=`echo ${line} | awk '{print $1}'`
    kafka_home=`echo ${line} | awk '{print $2}'`
    kafka_port=`echo ${line} | awk '{print $3}'`
    kafka_logs_home=`echo ${line} | awk '{print $4}'`
    kafka_topic=`echo ${line} | awk '{print $5}'`
    replication_factor=`echo ${line} | awk '{print $6}'`
    partitions=`echo ${line} | awk '{print $7}'`
done < $1

# 新建 kafka topic
# sh ${kafka_home}/bin/kafka-topics.sh --create --zookeeper ${host_name}:${kafka_port} --replication-factor ${replication_factor} --partitions ${partitions} --topic ${kafka_topic}

# 解压 kafka-logs
# tar -zxf kafka-logs.tar
scp -r -q kafka-logs ${host_name}:${kafka_logs_home}

# 拷贝环境配置脚本以及启动脚本
scp -q kafka-logs_install_config.sh $host_name:/opt/kafka-logs_install_config.sh

# 修改 kafka-logs 配置文件
echo "-----------------------配置 kafka-logs----------------------"
ins_home=$PWD
ssh -Tq root@${host_name} << EOF
sh /opt/kafka-logs_install_config.sh ${ins_home}/$1 ${ins_home}/$2 ${ins_home}/$3
rm -rf /opt/kafka-logs_install_config.sh
EOF

echo "-----------------------启动 kafka-logs 服务----------------------"
# 启动 kafka-logs
# sh ${kafka-logs_home}/start.sh

echo "-----------------------完成安装 kafka-logs----------------------"