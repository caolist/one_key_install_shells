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

# 设置各个节点的 host TODO 需改为通过配置文件读取参数形式
CLUSTER_HOSTS=(master slave1 slave2 slave3 slave4)

# 原始配置文件
ES_CONFIG_FILE_PATH="${ES_INSTALL_HOME}elasticsearch-6.3.2/config/"

# es 主目录
ES_INSTALL_HOME="/opt/elasticsearch/"

# 命令集合
CMD_ADDGROUP="groupadd es"
CMD_ADDUSER="useradd -r -g es es"
CMD_MKDIR_DATALOG="mkdir -p /es/data01 /es/data02 /esuser/logs"
CMD_CHOWNE="chown es:es -R ${ES_INSTALL_HOME}"
CMD_CHMOD="chmod 755 ${ES_INSTALL_HOME}elasticsearch-6.3.2/bin/elasticsearch"
CMD_CHOWNE_DATALOG="chown es:es -R /es"
CMD_CHMOD_DATALOG="chmod -R 755 /es"

echo "-----------------------开始安装 elasticSearch----------------------"

# 解压安装 elasticSearch
echo "-----------------------解压安装 elasticSearch----------------------"
tar -xzf elasticsearch-6.3.2.tar.gz

# 拷贝至各个节点，并进行配置
hosts=""
for node in ${CLUSTER_HOSTS[@]}
do
    hosts=$hosts"\"$node\","
    if test "$node" == "master"
    then
        echo "$node节点安装 es..."
        cp -r -f elasticsearch-6.3.2 $ES_INSTALL_HOME
        
        # 修改各配置项
        sed -i -e "/^#cluster.name:/Ic\cluster.name: ilog" \
        -e "/^#node.name:/Ic\node.name: ${node}" \
        -e "/^#path.data:/Ic\path.data: /es/data01,/es/data02" \
        -e "/^#path.logs:/Ic\path.logs: /es/logs" \
        -e "/^#network.host:/Ic\network.host: 0.0.0.0" \
        -e "/^#http.port:/Ic\http.port: 9200" \
        -e "/http.port:/a\#\\n# Set a tcp port for inner transport\\n#\\ntransport.tcp.port: 9300" \
        -e "/^#discovery.zen.ping.unicast.hosts:/Ic\discovery.zen.ping.unicast.hosts: [${hosts}]" \
        -e "/^#action.destructive_requires_name:/Ic\action.destructive_requires_name: true" \
        -e "/^#bootstrap.memory_lock/Ic\bootstrap.memory_lock: true" ${ES_CONFIG_FILE_PATH}elasticsearch.yml
        cat << EOF >> ${es_config}elasticsearch.yml
        node.master: true
        node.data: true
        http.cors.enabled: true
        http.cors.allow-origin: "*"
EOF
        
        # 添加 es 用户，建立数据日志目录并赋予权限
        $CMD_ADDGROUP
        $CMD_ADDUSER
        $CMD_CHOWNE
        $CMD_CHMOD
        $CMD_MKDIR_DATALOG
        $CMD_CHOWNE_DATALOG
    else
        echo "$node节点安装 es..."
        scp -r elasticsearch-6.3.2 $node:$ES_INSTALL_HOME
        
        # 修改各配置项
        sed -i -e "/^#cluster.name:/Ic\cluster.name: ilog" \
        -e "/^#node.name:/Ic\node.name: ${node}" \
        -e "/^#path.data:/Ic\path.data: /es/data01,/es/data02" \
        -e "/^#path.logs:/Ic\path.logs: /es/logs" \
        -e "/^#network.host:/Ic\network.host: 0.0.0.0" \
        -e "/^#http.port:/Ic\http.port: 9200" \
        -e "/http.port:/a\#\\n# Set a tcp port for inner transport\\n#\\ntransport.tcp.port: 9300" \
        -e "/^#discovery.zen.ping.unicast.hosts:/Ic\discovery.zen.ping.unicast.hosts: [${hosts}]" \
        -e "/^#action.destructive_requires_name:/Ic\action.destructive_requires_name: true" \
        -e "/^#bootstrap.memory_lock/Ic\bootstrap.memory_lock: true" ${ES_CONFIG_FILE_PATH}elasticsearch.yml
        cat << EOF >> ${es_config}elasticsearch.yml
        node.master: false
        node.data: true
        http.cors.enabled: true
        http.cors.allow-origin: "*"
EOF
        
        # 添加 es 用户，建立数据日志目录并赋予权限
        ssh -tt root@$node $CMD_ADDGROUP
        ssh -tt root@$node $CMD_ADDUSER
        ssh -tt root@$node $CMD_CHOWNE
        ssh -tt root@$node $CMD_CHMOD
        ssh -tt root@$node $CMD_MKDIR_DATALOG
        ssh -tt root@$node $CMD_CHOWNE_DATALOG
    fi
done

# 启动各个节点的 es 服务
for node in ${CLUSTER_HOSTS[@]};
do
    echo "$node节点启动 es..."
    if test "$node" == "$THIS_HOST"
    then
        su - es
        ${ES_INSTALL_HOME}elasticsearch-6.3.2/bin/elasticsearch -d
        exit
    else
        ssh -tt root@$node << EOF
        su - es
        ${ES_INSTALL_HOME}elasticsearch-6.3.2/bin/elasticsearch -d
        exit
EOF
    fi
done

# 通过 curl 访问 es 服务判断 elasticSearch 服务器是否正常运行
for node in ${CLUSTER_HOSTS[@]};
do
    is_es_running='curl -XGET $node:9200 | grep -i "master" | wc -l'
    if test $is_es_running = "1" ; then
        echo "$node节点 es 服务正在运行"
    else
        echo "$node节点 es 服务没有运行"
        exit
    fi
done

# 删除 es 安装文件
rm -rf elasticsearch-6.3.2.tar.gz

echo "-----------------------完成安装 elasticSearch----------------------"