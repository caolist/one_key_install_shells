#!/bin/bash
if [[ $# < 5 ]] ; then
    echo "Usage: $0 1.host_name 2.kafka_home 3.kafka_hosts 4.broker_id"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 创建消息持久化目录
mkdir /$2/kafkaLogs

# 修改各配置项
sed -i '/log.dirs/d' $1/config/server.properties
sed -i '/zookeeper.connect/d' $1/config/server.properties
sed -i -e "/^#broker.id=0:/Ic\broker.id=$4" $1/config/server.properties

cat << EOF >> $2/config/server.properties
log.dirs=/$2/kafkaLogs
zookeeper.connect=${kafka_hosts}
delete.topic.enable=true
auto.create.topics.enable=false
EOF

echo "-----------------------启动 kafka 服务----------------------"
cd ${kafka_home}/bin
./kafka-server-start.sh -daemon ../config/server.properties