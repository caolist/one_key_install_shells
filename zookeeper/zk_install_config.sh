#!/bin/bash
if [[ $# < 4 ]] ; then
    echo "Usage: $0 1.zk_home 2.data_path 3.log_path 4.zk_hosts 5.myid"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

cp $1/conf/zoo_sample.cfg $1/conf/zoo.cfg
sed -i '/dataDir/d' $1/conf/zoo.cfg

# 修改各配置项
cat << EOF >> $1/conf/zoo.cfg
dataDir=$2
dataLogDir=$3
EOF

i=0
for content in $4
do
    echo 'server.'${i}'='${content}'' >> $1/conf/zoo.cfg
    #     cat << EOF >> $1/conf/zoo.cfg
    # server.$i=$content
    # EOF
    #     i=$(($i+1))
done

mkdir -p $2
mkdir -p $3

touch $2/myid
echo $5 > $2/myid

echo 'ZOOKEEPER_HOME='$1'' >> /etc/profile
echo 'PATH=$PATH:$ZOOKEEPER_HOME/bin' >> /etc/profile
echo 'export ZOOKEEPER_HOME' >> /etc/profile
echo 'export PATH' >> /etc/profile
source /etc/profile

echo "-----------------------启动 zookeeper 服务----------------------"
sh $1/bin/zkServer.sh start

echo "-----------------------查看 zookeeper 服务状态----------------------"
sh $1/bin/zkServer.sh status