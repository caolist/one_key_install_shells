#!/bin/bash
if [[ $# < 4 ]] ; then
    echo "Usage: $0 1.host_name 2.kafka_home 3.kafka_hosts 4.broker_id"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 创建消息持久化目录
if [[ ! -e $2/kafkaLogs ]] ; then
    mkdir -p $2/kafkaLogs
fi

# 修改各配置项
sed -i -e "/^broker.id=0/Ic\broker.id=$4" \
-e "/^log.dirs=\/tmp\/kafka-logs/Ic\log.dirs=$2/kafkaLogs" \
-e "/^zookeeper.connect=localhost:2181/Ic\zookeeper.connect=$3" $2/config/server.properties
sed -i -e '$a\delete.topic.enable=true' $2/config/server.properties
sed -i -e '$a\auto.create.topics.enable=false' $2/config/server.properties

echo "-----------------------启动 kafka 服务----------------------"
cd $2/bin
./kafka-server-start.sh -daemon ../config/server.properties

sleep 3

echo "-----------------------查看 kafka 服务状态----------------------"
is_kafka_running=`jps | grep Kafka | wc -l`
if [[ $is_kafka_running = "1" ]] ; then
    echo 'kafka 启动成功'
else
    echo 'kafka 启动失败'
    exit
fi