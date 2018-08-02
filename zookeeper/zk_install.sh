#/bin/sh
# created by caoli 2018/08/02
# -----------------------------------------------------------------------------
# shell script for install ZooKeeper (version 3.4.12)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
set -x

# 脚本参数解析
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.zk node config file path(file content format as follows:) 2.zk version"
    echo "example:"
    echo "./zk_install.sh zk_config 3.4.12"
    echo "1.host_name 2.port1 3.port2 4.zk_home 5.data_path 6.log_path 7.zk_myid"
    echo "example:"
    echo "node01 2888 3888 /opt/zookeeper /var/lib/zookeeper /var/lib/zookeeper 1"
    echo "node02 2888 3888 /opt/zookeeper /var/lib/zookeeper /var/lib/zookeeper 2"
    echo "node05 2888 3888 /opt/zookeeper /var/lib/zookeeper /var/lib/zookeeper 3"
    exit
fi

# es 版本号
zk_version=$2
echo $zk_version

# 读取配置文件中的所有 zk 节点名称
while read line || [ -n "$line" ]
do
    one_host=`echo ${line} | awk '{print $1}'`
    if [ -z ${zk_hosts} ] ; then
        zk_hosts=${one_host}
    else
        zk_hosts=${zk_hosts}","${one_host}
    fi
done < $1

echo $zk_hosts

echo "-----------------------开始安装 zookeeper----------------------"

# 解压安装 zookeeper
tar -zxvf zookeeper-${zk_version}.tar.gz

cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 zk 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    port1=`echo ${line} | awk '{print $2}'`
    port2=`echo ${line} | awk '{print $3}'`
    zk_home=`echo ${line} | awk '{print $4}'`
    data_path=`echo ${line} | awk '{print $5}'`
    log_path=`echo ${line} | awk '{print $6}'`
    zk_myid=`echo ${line} | awk '{print $7}'`
    
    echo "$host_name 节点安装 zk..."
    scp -r zookeeper-${zk_version} $host_name:$zk_home
    
    # 拷贝 zookeeper 中 conf 目录下的 zoo_sample.cfg 为 zoo.cfg
    # 删除原 dataDir
    # 增加 dataDir dataLogDir
    # 添加server.0、server.1、server.2...
    # data 目录下创建 myid 文件，并添加内容
    ssh -t root@${host_name} << EOF
cp ${zk_home}/conf/zoo_sample.cfg ${zk_home}/conf/zoo.cfg
sed -i '/dataDir/d' ${zk_home}/conf/zoo.cfg
mkdir -p log_path
mkdir -p zk_myid
echo 'dataDir='${data_path}'' >> zoo.cfg
echo 'dataLogDir='${log_path}'' >> zoo.cfg

i=1
for ip in $zk_hosts
do
    echo 'server.'$i'='$ip':2888:3888' >> zoo.cfg
    i=$(($i+1))
done

touch ${data_path}/myid
echo $zk_myid > ${data_path}/myid

echo 'ZOOKEEPER_HOME='$1'' >> /etc/profile
echo 'PATH=$PATH:$ZOOKEEPER_HOME/bin' >> /etc/profile
echo 'export ZOOKEEPER_HOME' >> /etc/profile
echo 'export PATH' >> /etc/profile
source /etc/profile

sh ${zk_home}/bin/zkServer.sh start
EOF
done

# 删除 zk 安装文件
rm -rf zookeeper-${zk_version}

echo "-----------------------完成安装 zookeeper----------------------"