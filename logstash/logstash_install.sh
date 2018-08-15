#/bin/sh
# created by caoli 2018/08/08
# -----------------------------------------------------------------------------
# shell script for install logstash (version 6.3.2)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
set -x

# 脚本参数解析
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.logstash node config file path(file content format as follows:) 2.logstash version"
    echo "example:"
    echo "./logstash_install.sh logstash_config 6.3.2"
    echo "1.host_name 2.logstash_home 3.logstash_config_files"
    echo "example:"
    echo "node01 /opt/logstash a.yml,b.yml"
    echo "node02 /opt/logstash c.yml,d.yml"
    echo "node03 /opt/logstash e.yml,f.yml"
    exit
fi

# logstash 版本号
logstash_version=$2
echo $logstash_version

echo "-----------------------开始安装 logstash----------------------"

# 解压安装 logstash
tar -zxf logstash-${logstash_version}.tar.gz

cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 logstash 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    logstash_home=`echo ${line} | awk '{print $2}'`
    logstash_config_files=`echo ${line} | awk '{print $3}'`
    
    echo "$host_name 节点安装 logstash..."
    ssh -t root@${host_name} << EOF
mkdir -p $logstash_home
EOF
    scp -r -q logstash-${logstash_version}/* $host_name:$logstash_home
    
    # 拷贝 logstash 配置文件到各个节点的 logstash/conf 目录
    for config_file in `echo ${logstash_config_files} | awk -F "," '{for(i=1;i<=NF;i++){print $i}}'`
    do
        echo "拷贝 $config_file"
        scp $config_file $host_name:${logstash_home}/config
    done
    
done

# 启动各个节点的 logstash 实例
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 logstash 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    logstash_home=`echo ${line} | awk '{print $2}'`
    logstash_config_files=`echo ${line} | awk '{print $3}'`
    
    echo "$host_name 节点启动 logstash..."
    
    # 启动各个实例
    #     for config_file in `echo ${logstash_config_files} | awk -F "," '{for(i=1;i<=NF;i++){print $i}}'`
    #     do
    #         echo "$host_name 节点启动 logstash ${config_file} 实例..."
    #         ssh -t root@${host_name} << EOF
    #     ${logstash_home}/bin/logstash -f config_file
    # EOF
    
    #     done
    
done

# 删除 logstash 安装文件
rm -rf logstash-${logstash_version}

echo "-----------------------完成安装 logstash----------------------"
