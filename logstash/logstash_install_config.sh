#!/bin/bash
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.host_name 2.log_file_path"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 创建日志文件存放路径
if [[ ! -e $2 ]] ; then
    mkdir -p $2
fi

rm -rf /opt/logstash_install_config.sh