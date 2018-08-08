#/bin/sh
# created by caoli 2018/08/03
# -----------------------------------------------------------------------------
# shell script for install Kafka (version 2.11-2.0.0)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
set -x

# 脚本参数解析
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.kafka node config file path(file content format as follows:) 2.kafka version"
    echo "example:"
    echo "./kafka_install.sh kafka_config 2.11-2.0.0"
    echo "1.host_name 2.kafka_home 3.zk_port 34.broker_id"
    echo "example:"
    echo "node01 /opt/kafka 2181 1"
    echo "node02 /opt/kafka 2181 2"
    echo "node05 /opt/kafka 2181 3"
    exit
fi

# kafka 版本号
kafka_version=$2
echo $kafka_version

# 读取配置文件中的所有 kafka 节点名称
while read line || [ -n "$line" ]
do
    one_host=`echo ${line} | awk '{print $1}'`
    one_port=`echo ${line} | awk '{print $3}'`
    if [ -z ${kafka_hosts} ] ; then
        kafka_hosts=${one_host}:${one_port}
    else
        kafka_hosts=${kafka_hosts}","${one_host}:${one_port}
    fi
done < $1

echo $kafka_hosts

echo "-----------------------开始安装 kafka----------------------"

# 解压安装 kafka
tar -zxvf kafka_${kafka_version}.tgz

cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 zk 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    kafka_home=`echo ${line} | awk '{print $2}'`
    broker_id=`echo ${line} | awk '{print $4}'`
    
    echo $host_name
    echo $kafka_home
    echo $broker_id
    
    echo "$host_name 节点安装 kafka..."
    scp -r kafka_${kafka_version}/* $host_name:$kafka_home
    
    # 拷贝环境配置脚本以及启动脚本
    scp kafka_install_config.sh $host_name:/opt/kafka_install_config.sh
    
    echo "-----------------------配置 kafka----------------------"
    ssh -t root@${host_name} << EOF
sh /opt/kafka_install_config.sh $host_name $kafka_home $kafka_hosts $broker_id
rm -rf /opt/kafka_install_config.sh
EOF
done

# 删除 kafka 安装文件
rm -rf kafka_${kafka_version}

echo "-----------------------完成安装 kafka----------------------"