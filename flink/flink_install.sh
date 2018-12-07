#/bin/sh
# created by caoli 2018/11/30
# -----------------------------------------------------------------------------
# shell script for installing flink (version 1.6.2-bin-hadoop27-scala_2.11)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
# set -x

# 脚本参数解析
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.flink node config file path(file content format as follows:) 2.flink version"
    echo "example:"
    echo "./flink_install.sh 1.6.2-bin-hadoop27-scala_2.11"
    echo "1.host name 2.flink home 3.is_master 4.port"
    echo "example:"
    echo "hdp01 /opt/flink true 8081"
    echo "hdp02 /opt/flink true 8081"
    echo "hdp03 /opt/flink true 8081"
    exit
fi

# flink 版本号
flink_version=$2
echo $flink_version

echo "-----------------------开始安装 flink----------------------"

# 解压安装 flink
tar -xzf flink-${flink_version}.tgz

# 删除 masters slaves 配置文件中默认内容
> flink-${flink_version}/conf/masters
> flink-${flink_version}/conf/slaves

# 修改解压文件中的配置文件内容
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 flink 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    is_master=`echo ${line} | awk '{print $3}'`
    port=`echo ${line} | awk '{print $4}'`
    
    if [[ $is_master = "true" ]] ; then
        sed -i -e "/^jobmanager.rpc.address: localhost/Ic\jobmanager.rpc.address: ${host_name}" flink-${flink_version}/conf/flink-conf.yaml
        sed -i -e "/^taskmanager.numberOfTaskSlots: 1/Ic\taskmanager.numberOfTaskSlots: 2" flink-${flink_version}/conf/flink-conf.yaml
        echo ''${host_name}':'${port}'' >> flink-${flink_version}/conf/masters
    else
        echo ${host_name} >> flink-${flink_version}/conf/slaves
    fi
    
done

# 根据配置文件进行操作
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 flink 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    flink_home=`echo ${line} | awk '{print $2}'`
    
    echo "$host_name 节点安装 flink..."
    ssh -t root@${host_name} << EOF
mkdir -p $flink_home
EOF
    scp -r -q flink-${flink_version}/* $host_name:$flink_home
    
    # 拷贝环境配置脚本以及启动脚本
    scp -q flink_install_config.sh $host_name:/opt/flink_install_config.sh
    
    echo "-----------------------配置 flink----------------------"
    ssh -t root@${host_name} << EOF
sh /opt/flink_install_config.sh $flink_home
rm -rf /opt/flink_install_config.sh
EOF
done

echo "-----------------------启动 flink----------------------"
# 修改解压文件中的配置文件内容
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 flink 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    flink_home=`echo ${line} | awk '{print $2}'`
    is_master=`echo ${line} | awk '{print $3}'`
    
    if [[ $is_master = "true" ]] ; then
        ssh -t root@${host_name} << EOF
sh $flink_home/bin/start-cluster.sh
EOF
    fi
done

# 删除 flink 安装文件
rm -rf flink-${flink_version}

echo "-----------------------完成安装 flink----------------------"