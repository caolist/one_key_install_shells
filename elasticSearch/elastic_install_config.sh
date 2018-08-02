#!/bin/bash
if [[ $# < 11 ]] ; then
    echo "Usage: $0 1.cluster_name 2.node_name 3.data_path 4.log_path 5.network_host 6.http_port 7.transport_tcp_port 8.zen_hosts 9.es_home 10.is_master_node 11.is_master_node"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

es_home=$9

# 修改各配置项
sed -i -e "/^#cluster.name:/Ic\cluster.name: $1" \
-e "/^#node.name:/Ic\node.name: $2" \
-e "/^#path.data:/Ic\path.data: $3" \
-e "/^#path.logs:/Ic\path.logs: $4" \
-e "/^#network.host:/Ic\network.host: $5" \
-e "/^#http.port:/Ic\http.port: $6" \
-e "/http.port:/a\#\\n# Set a tcp port for inner transport\\n#\\ntransport.tcp.port: $7" \
-e "/^#discovery.zen.ping.unicast.hosts:/Ic\discovery.zen.ping.unicast.hosts: [$8]" \
-e "/^#action.destructive_requires_name:/Ic\action.destructive_requires_name: true" \
-e "/^#bootstrap.memory_lock/Ic\bootstrap.memory_lock: true" ${es_home}/config/elasticsearch.yml

shift 9

    cat << EOF >> ${es_home}/config/elasticsearch.yml
node.master: $1
node.data: $2
http.cors.enabled: true
http.cors.allow-origin: "*"
EOF