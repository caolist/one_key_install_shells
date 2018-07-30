#/bin/sh
# created by caoli 2018/07/30
# -----------------------------------------------------------------------------
# shell script for install ElasticSearch (version 6.2.3)
# -----------------------------------------------------------------------------

# 设置调试模式
set -x

# 设置各个节点的 host
CLUSTER_HOSTS=(master slave1 slave2 slave3 slave4)

# 原始配置文件
ES_CONFIG_FILE="elasticsearch.yml"

# es 主目录
ES_INSTALL_HOME="/opt/elasticsearch/"

# 命令集合
COMMAND_ADDGROUP="groupadd es"
COMMAND_ADDUSER="useradd -r -g es es"
COMMAND_MKDIR_DATALOG="mkdir -p /esuser/data /esuser/log"
COMMAND_CHOWNES="chown es:es -R $ES_INSTALL_HOME"
COMMAND_CHOWNES_DATALOG="chown es:es -R /es"

echo "-----------------------开始安装 elasticSearch----------------------"

# 解压安装 elasticSearch
echo "-----------------------解压安装 elasticSearch----------------------"
tar -xzf elasticsearch-6.3.2.tar.gz

# 拷贝至各个节点，并进行配置
for node in ${CLUSTER_HOSTS[@]}
do
    echo $node
    if test "$node" == "master"
    then
        echo "$node节点安装es..."
        cp -r -f elasticsearch-6.3.2 $ES_INSTALL_HOME
        cp elasticsearch.yml {$ES_INSTALL_HOME}elasticsearch-6.3.2/config/
        $COMMAND_ADDGROUP
        $COMMAND_ADDUSER
        $COMMAND_CHOWNES
        $COMMAND_MKDIR_DATALOG
        $COMMAND_CHOWNES_DATALOG
    else
        echo "$node节点安装es..."
        ssh -t -p 22 root@$node $ES_INSTALL_HOME
        scp -r elasticsearch-6.3.2 $node:$ES_INSTALL_HOME
        scp elasticsearch.yml $node:{$ES_INSTALL_HOME}elasticsearch-6.3.2/config/
        
        scp start_es.sh $node:$ES_INSTALL_HOME
        
        sed -i "s/node.name: master/node.name: $node/g" ${es_config}elasticsearch.yml
        sed -i "s/node.master: true/node.master: false/g" ${es_config}elasticsearch.yml
        sed -i "s/node.data: true/node.data: false/g" ${es_config}elasticsearch.yml
        
        ssh -t -p 22 root@$node $COMMAND_ADDGROUP
        ssh -t -p 22 root@$node $COMMAND_ADDUSER
        ssh -t -p 22 root@$node $COMMAND_CHOWNES
        ssh -t -p 22 root@$node $COMMAND_MKDIR_DATALOG
        ssh -t -p 22 root@$node $COMMAND_CHOWNES_DATALOG
    fi
done

# 启动各个节点的 es 服务
for node in ${CLUSTER_HOSTS[@]};
do
    echo $node
    if test "$node" == "$THIS_HOST"
    then
        su - es -c "${ES_INSTALL_HOME}elasticsearch-6.3.2/bin/service/elasticsearch start"
    else
        echo "$node节点启动es..."
        
        #ssh -t -p 22 es@$node "${ES_INSTALL_HOME}elasticsearch-6.3.2/bin/service/elasticsearch start"
        ssh -t -p 22 root@$node "${ES_INSTALL_HOME}start_es"
    fi
done

# 通过 curl 访问 es 服务判断 elasticSearch master 服务器是否正常运行
is_es_running='curl -XGET master:9200 | grep -i "master" | wc -l'
if test $is_es_running = "1" ; then
    echo 'es 主节点服务正在运行'
else
    echo 'es 主节点服务没有运行'
    exit
fi

# 删除 es 安装文件
rm -rf elasticsearch-6.3.2.tar.gz

echo "-----------------------完成安装 elasticSearch----------------------"