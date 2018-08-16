#/bin/sh
# created by caoli 2018/08/15
# -----------------------------------------------------------------------------
# shell script for install kafka-logs
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
# set -x

# 脚本参数解析
if [[ $# < 1 ]] ; then
    echo "Usage: $0 1.kafka-logs node config file path(file content format as follows:)"
    echo "example:"
    echo "./kafka-logs_install.sh kafka-logs_config"
    echo "1.host_name 2.kafka_home 3.zk_port"
    echo "example:"
    echo "node01 /opt/kafka 2181"
    echo "node02 /opt/kafka 2181"
    echo "node03 /opt/kafka 2181"
    exit
fi

echo "-----------------------开始安装 kafka-logs----------------------"

# 新建 kafka topic
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test

# 修改 kafka-logs 配置文件


# 启动 kafka-logs


