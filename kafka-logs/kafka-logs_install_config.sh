#!/bin/bash
if [[ $# < 3 ]] ; then
    echo "Usage: $0 1.kafka-logs config file path 2.elastic config file path 3.mysql config file path"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 设置调试模式
# set -x

# 读取 kafka
while read line || [ -n "$line" ]
do
    host_name=`echo ${line} | awk '{print $1}'`
    kafka_home=`echo ${line} | awk '{print $2}'`
    kafka_port=`echo ${line} | awk '{print $3}'`
    kafka_logs_home=`echo ${line} | awk '{print $4}'`
    kafka_topic=`echo ${line} | awk '{print $5}'`
    replication_factor=`echo ${line} | awk '{print $6}'`
    partitions=`echo ${line} | awk '{print $7}'`
    bootstrap_servers=`echo ${line} | awk '{print $1}'`
    bootstrap_servers_port=`echo ${line} | awk '{print $8}'`
    zookeeper_hosts=`echo ${line} | awk '{print $9}'`
    consumer_group_id=`echo ${line} | awk '{print $10}'`
done < $1

# 读取 es 配置
while read line || [ -n "$line" ]
do
    es_cluster=`echo ${line} | awk '{print $1}'`
    es_host=`echo ${line} | awk '{print $2}'`
    es_port=`echo ${line} | awk '{print $3}'`
    es_index_prifix=`echo ${line} | awk '{print $4}'`
done < $2

# 读取 mysql 配置
while read line || [ -n "$line" ]
do
    mysql_url=`echo ${line} | awk '{print $1}'`
    mysql_user=`echo ${line} | awk '{print $2}'`
    mysql_password=`echo ${line} | awk '{print $3}'`
done < $3

# 修改 db.properties
sed -i '/db.url/d' ${kafka_logs_home}/lib/conf/db.properties
sed -i '/db.username/d' ${kafka_logs_home}/lib/conf/db.properties
sed -i '/db.password/d' ${kafka_logs_home}/lib/conf/db.properties
sed -i -e '$a\db.url=jdbc:mysql://'${mysql_url}'' ${kafka_logs_home}/lib/conf/db.properties
sed -i -e '$a\db.username='${mysql_user}'' ${kafka_logs_home}/lib/conf/db.properties
sed -i -e '$a\db.password='${mysql_password}'' ${kafka_logs_home}/lib/conf/db.properties

# 修改 elasticSearch.properties
sed -i '/es.cluster/d' ${kafka_logs_home}/lib/conf/elasticSearch.properties
sed -i '/es.host/d' ${kafka_logs_home}/lib/conf/elasticSearch.properties
sed -i '/es.host.port/d' ${kafka_logs_home}/lib/conf/elasticSearch.properties
sed -i '/es.index.prifix/d' ${kafka_logs_home}/lib/conf/elasticSearch.properties
sed -i -e '$a\es.cluster='${es_cluster}'' ${kafka_logs_home}/lib/conf/elasticSearch.properties
sed -i -e '$a\es.host='${es_host}'' ${kafka_logs_home}/lib/conf/elasticSearch.properties
sed -i -e '$a\es.host.port='${es_port}'' ${kafka_logs_home}/lib/conf/elasticSearch.properties
sed -i -e '$a\es.index.prifix='${es_index_prifix}'' ${kafka_logs_home}/lib/conf/elasticSearch.properties

# 修改 elasticSearchIndexMapping.xml
rm -rf ${kafka_logs_home}/lib/conf/elasticSearchIndexMapping.xml
touch ${kafka_logs_home}/lib/conf/elasticSearchIndexMapping.xml

cat << EOF >> ${kafka_logs_home}/lib/conf/elasticSearchIndexMapping.xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- elasticSearch 索引mapping字段与kafka消费的json字段匹配关系-->
<root>
	<index>
		<index-topic name="${kafka_topic}"/>
		<index-cluster name="${es_cluster}" host_ip="${es_host}" host_port="${es_port}"
		<index-prefix name="${es_index_prifix}" type="log"/>
		<mapping>
			<field name="message" type="String" source="message"/>
			<field name="time" type="String" source="time"/>
			<field name="host" type="String" source="host"/>
			<!-- <field name="level" type="String0" source="level"/> -->
			<field name="@timestamp" type="Date" source="@timestamp"/>
			<field name="sysno" type="String" source="sysno"/>
		</mapping>
	</index>
</root>
EOF

# 修改 kafka.properties
sed -i '/kafka.consumer.bootstrap.servers/d' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i '/kafka.consumer.zookeeper.connect/d' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i '/kafka.consumer.group.id/d' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i '/consumer.topics/d' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i '/kafka.producer.metadata.broker.list/d' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i -e '$a\kafka.consumer.bootstrap.servers='${bootstrap_servers}':'${bootstrap_servers_port}'' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i -e '$a\kafka.consumer.zookeeper.connect='${zookeeper_hosts}'' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i -e '$a\kafka.consumer.group.id='${consumer_group_id}'' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i -e '$a\consumer.topics='${kafka_topic}'' ${kafka_logs_home}/lib/conf/kafka.properties
sed -i -e '$a\kafka.producer.metadata.broker.list='${bootstrap_servers}':'${bootstrap_servers_port}'' ${kafka_logs_home}/lib/conf/kafka.properties