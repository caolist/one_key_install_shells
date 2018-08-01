#!/bin/bash
if [[ $# < 3 ]] ; then
    echo "Usage: $0 1.es username 2.es home 3.mode name"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

su - $1
$2/bin/elasticsearch -d
exit

sleep 60

# 通过 curl 访问 es 服务判断 elasticSearch 服务器是否正常运行
is_es_running='curl -XGET $node:9200 | grep -i $3 | wc -l'
if test $is_es_running = "1" ; then
    echo "$3 节点 es 服务正在运行"
else
    echo "$3 节点 es 服务没有运行"
    exit
fi