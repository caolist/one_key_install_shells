#/bin/sh
# created by caoli 2018/12/03
# -----------------------------------------------------------------------------
# shell script for installing hadoop (version 2.7.7)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ;
then
    echo "请使用 root 用户执行!"
    exit
fi

#check the java home
if [ "$JAVA_HOME" = "" ]
then
    echo "JAVA_HOME IS EMPTY"
    exit 1
fi

# 设置调试模式
# set -x

# 脚本参数解析
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.hadoop node config file path(file content format as follows:) 2.hadoop version"
    echo "example:"
    echo "./hadoop_install.sh hadoop_config 2.7.7"
    echo "1.host_name 2.hadoop_home 3.is_master"
    echo "example:"
    echo "node01 /opt/hadoop true"
    echo "node02 /opt/hadoop false"
    echo "node03 /opt/hadoop false"
    exit
fi

hadoop_version=$2
echo $hadoop_version

echo "-----------------------开始安装 hadoop----------------------"

# 解压安装 hadoop
tar -xzf hadoop-${hadoop_version}.tar.gz

# 删除 slaves 配置文件中默认内容
> hadoop-${hadoop_version}/etc/hadoop/slaves

# 修改解压文件中的配置文件内容
touch tempMaster
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 hadoop 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    is_master=`echo ${line} | awk '{print $3}'`
    
    if [[ $is_master = "false" ]] ; then
        echo ${host_name} >> hadoop-${hadoop_version}/etc/hadoop/slaves
    else
        echo ${host_name} >> hadoop-${hadoop_version}/etc/hadoop/slaves
        master=${host_name}
        echo $master >> tempMaster
    fi
    
done

master=`cat tempMaster | head -1 | awk '{print $1}'`
rm -rf tempMaster

# num_of_slaves=0
# for slave in `cat hadoop-${hadoop_version}/etc/hadoop/slaves`
# do
#     num_of_slaves=`expr $num_of_slaves + 1`
# done

sed -i '18,$d' hadoop-${hadoop_version}/etc/hadoop/core-site.xml
echo "<configuration>
<property>
<name>hadoop.tmp.dir</name>
<value>/home/hadoop/tmp</value>
</property>
<property>
<name>fs.default.name</name>
<value>hdfs://$master:9000</value>
</property>
<property>
<name>io.file.buffer.size</name>
<value>131072</value>
</property>
</configuration>" >> hadoop-${hadoop_version}/etc/hadoop/core-site.xml

sed -i '18,$d' hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml
echo "<configuration>
<property>
<name>dfs.name.dir</name>
<value>/home/hadoop/hdfs/name</value>
</property>
<property>
<name>dfs.data.dir</name>
<value>/home/hadoop/hdfs/data</value>
</property>
<property>
<name>dfs.replication</name>
<value>2</value>
</property>
<property>
<name>dfs.permissions</name>
<value>true</value>
</property>
</configuration>" >> hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml

sed -i '18,$d' hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml.template
echo "<configuration>
<property>
<name>mapred.job.tracker</name>
<value>$master:49001</value>
</property>
<property>
<name>mapred.local.dir</name>
<value>/home/hadoop/var</value>
</property>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>
</configuration>" >> hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml.template

if [ ! -f hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml ]
then
    cp hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml.template hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml
else
    echo "hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml exist"
fi

sed -i '15,$d' hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml
echo "<configuration>
<property>
<name>yarn.resourcemanager.hostname</name>
<value>$master</value>
</property>
<property>
<name>yarn.resourcemanager.address</name>
<value>${yarn.resourcemanager.hostname}:8032</value>
</property>
<property>
<name>yarn.resourcemanager.scheduler.address</name>
<value>${yarn.resourcemanager.hostname}:8030</value>
</property>
<property>
<name>yarn.resourcemanager.webapp.address</name>
<value>${yarn.resourcemanager.hostname}:8088</value>
</property>" >> hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml

echo "<property>
<name>yarn.resourcemanager.webapp.https.address</name>
<value>${yarn.resourcemanager.hostname}:8090</value>
</property>
<property>
<name>yarn.resourcemanager.resource-tracker.address</name>
<value>${yarn.resourcemanager.hostname}:8031</value>
</property>
<property>
<name>yarn.resourcemanager.admin.address</name>
<value>${yarn.resourcemanager.hostname}:8033</value>
</property>" >> hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml

echo "<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
<property>
<name>yarn.scheduler.maximum-allocation-mb</name>
<value>32768</value>
</property>
<property>
<name>yarn.nodemanager.vmem-pmem-ratio</name>
<value>2.1</value>
</property>
<property>
<name>yarn.nodemanager.resource.memory-mb</name>
<value>32768</value>
</property>
<property>
<name>yarn.nodemanager.vmem-check-enabled</name>
<value>false</value>
</property>
</configuration>" >> hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml

sed -i "s,^export JAVA_HOME.*,export JAVA_HOME=${JAVA_HOME},g" hadoop-${hadoop_version}/etc/hadoop/hadoop-env.sh

# 根据配置文件进行操作
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 hadoop 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    hadoop_home=`echo ${line} | awk '{print $2}'`
    
    echo "$host_name 节点安装 hadoop..."
    ssh -t root@${host_name} << EOF
mkdir -p $hadoop_home
EOF
    scp -r -q hadoop-${hadoop_version}/* $host_name:$hadoop_home
    
    # 拷贝环境配置脚本以及启动脚本
    scp -q hadoop_install_config.sh $host_name:/opt/hadoop_install_config.sh
    
    echo "-----------------------配置 hadoop----------------------"
    ssh -t root@${host_name} << EOF
sh /opt/hadoop_install_config.sh $hadoop_home
rm -rf /opt/hadoop_install_config.sh
EOF
done

# echo "-----------------------启动 hadoop----------------------"
# # 修改解压文件中的配置文件内容
# cat $1 | while read line || [ -n "$line" ]
# do
    
#     # 读取 hadoop 配置文件参数值
#     host_name=`echo ${line} | awk '{print $1}'`
#     hadoop_home=`echo ${line} | awk '{print $2}'`
#     is_master=`echo ${line} | awk '{print $3}'`
    
#     if [[ $is_master = "true" ]] ; then
#         ssh -t root@${host_name} << EOF
# sh $hadoop_home/bin/hadoop namenode -format
# sh $hadoop_home/sbin/sbin/start-all.sh
# EOF
#     fi
# done

# 删除 hadoop 安装文件
rm -rf hadoop-${hadoop_version}

echo "-----------------------完成安装 hadoop----------------------"