#/bin/sh
# created by caoli 2018/07/30
# -----------------------------------------------------------------------------
# shell script for install ElasticSearch (version 6.2.3)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
set -x

# 脚本参数解析
if [[ $# < 4 ]] ; then
    echo "Usage: $0 1.es username 2.es cluster name 3.es node config file path(file content format as follows:) 4.es version"
    echo "1.host name 2.node name 3.es home 4.data path(multi) 5.log path 6.is master node 7.is data node 8.network host 9.http port 10.transport tcp port 11.java memory size"
    echo "example:"
    echo "node01 esnode01 /opt/elasticsearch /es/data01,/es/data02 /es/logs true true 0.0.0.0 9200 9300 4g"
    echo "node02 esnode02 /opt/elasticsearch /es/data01,/es/data02 /es/logs false true 0.0.0.0 9200 9300 512m"
    exit
fi

# es 版本号
es_version=$4

echo $es_version

# 读取配置文件中的所有 es 节点名称
while read line || [ -n "$line" ]
do
    one_host=`echo ${line} | awk '{print $1}'`
    if [ -z ${zen_hosts} ] ; then
        zen_hosts=${one_host}
    else
        zen_hosts=${zen_hosts}","${one_host}
    fi
done < $3

echo $zen_hosts

echo "-----------------------开始安装 elasticSearch----------------------"

# 解压安装 elasticSearch
tar -xzf elasticsearch-${es_version}.tar.gz

# 根据配置文件进行操作
cat $3 | while read line || [ -n "$line" ]
do
    
    # 读取 es 配置文件参数值
    cluster_name=$2
    host_name=`echo ${line} | awk '{print $1}'`
    mode_name=`echo ${line} | awk '{print $2}'`
    es_home=`echo ${line} | awk '{print $3}'`
    data_path=`echo ${line} | awk '{print $4}'`
    log_path=`echo ${line} | awk '{print $5}'`
    is_master_node=`echo ${line} | awk '{print $6}'`
    is_data_node=`echo ${line} | awk '{print $7}'`
    network_host=`echo ${line} | awk '{print $8}'`
    http_port=`echo ${line} | awk '{print $9}'`
    transport_tcp_port=`echo ${line} | awk '{print $10}'`
    java_mem_size=`echo ${line} | awk '{print $11}'`
    
    echo "$node 节点安装 es..."
    scp -r elasticsearch-${es_version} $host_name:$es_home
    
    # 拷贝环境配置脚本以及启动脚本
    scp elastic_install_env.sh $host_name:/opt/temp_scripts/elastic_install_env.sh
    scp elastic_install_start.sh $host_name:/opt/temp_scripts/elastic_install_start.sh
    
    # 修改各配置项
    sed -i -e "/^#cluster.name:/Ic\cluster.name: ${cluster_name}" \
    -e "/^#node.name:/Ic\node.name: ${mode_name}" \
    -e "/^#path.data:/Ic\path.data: ${data_path}" \
    -e "/^#path.logs:/Ic\path.logs: ${log_path}" \
    -e "/^#network.host:/Ic\network.host: ${network_host}" \
    -e "/^#http.port:/Ic\http.port: ${http_port}" \
    -e "/http.port:/a\#\\n# Set a tcp port for inner transport\\n#\\ntransport.tcp.port:  ${transport_tcp_port}" \
    -e "/^#discovery.zen.ping.unicast.hosts:/Ic\discovery.zen.ping.unicast.hosts: [${zen_hosts}]" \
    -e "/^#action.destructive_requires_name:/Ic\action.destructive_requires_name: true" \
    -e "/^#bootstrap.memory_lock/Ic\bootstrap.memory_lock: true" ${es_home}/config/elasticsearch.yml
    
    cat << EOF >> ${es_home}/config/elasticsearch.yml
    node.master: $is_master_node
    node.data: $is_data_node
    http.cors.enabled: true
    http.cors.allow-origin: "*"
EOF
    
    # 添加 es 用户，建立数据日志目录并赋予权限,接着启动 es 服务
    ssh -tt root@${host_name} << EOF
    sh /opt/temp_scripts/elastic_install_env.sh $1 $es_home $data_path $log_path
    sh /opt/temp_scripts/elastic_install_start.sh

    rm -rf /opt/temp_scripts
EOF
done

# 删除 es 安装文件
rm -rf elasticsearch-${es_version}

echo "-----------------------完成安装 elasticSearch----------------------"