#/bin/sh
# created by caoli 2018/09/06
# -----------------------------------------------------------------------------
# shell script for install solrCloud (version 7.4.0)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
# set -x

# 脚本参数解析
if [[ $# < 2 ]] ; then
    echo "Usage: $0 1.solr node config file path(file content format as follows:) 2.solr version 3.solr_dir 4.zk_hosts"
    echo "example:"
    echo "./solr_install.sh solr_config 7.4.0 /opt/solr node01:2181,node02:2182,node03:2183"
    echo "1.host_name 2.solr_home 3.tomcat_solr_path 4.solr_port"
    echo "example:"
    echo "node01 /opt/solrhome /opt/tomcat_solr 9966"
    echo "node02 /opt/solrhome /opt/tomcat_solr 9966"
    echo "node03 /opt/solrhome /opt/tomcat_solr 9966"
    exit
fi

# solr 版本号
solr_version=$2
echo $solr_version

# 检测是否安装 tomcat
if [[ ! -e "/opt/tomcat" ]] ; then
    echo "请先安装 tomcat!"
    exit
fi

cp -R -f /opt/tomcat tomcat_solr

echo "-----------------------开始安装 solrCloud----------------------"

# 解压安装 solr
tar -zxf solr-${solr_version}.tgz
cp -r solr-${solr_version} /opt/solr

# 把 solr 部署到 tomcat 下
cp -R -f solr-${solr_version}/server/solr-webapp/webapp tomcat_solr/webapps/solr
cp -R -f solr-${solr_version}/server/lib/ext/* tomcat_solr/webapps/solr/WEB-INF/lib/
cp -R -f solr-${solr_version}/server/lib/metrics* tomcat_solr/webapps/solr/WEB-INF/lib/
cp -R -f solr-${solr_version}/server/resources/log4j* tomcat_solr/webapps/solr/WEB-INF/classes/

# 创建 solrhome
cp -R -f solr-${solr_version}/server/solr solrhome

# 安装 tomcat_solr 以及 solrhome
cat $1 | while read line || [ -n "$line" ]
do
    
    # 读取 solr 配置文件参数值
    host_name=`echo ${line} | awk '{print $1}'`
    solr_home_path=`echo ${line} | awk '{print $2}'`
    tomcat_solr_path=`echo ${line} | awk '{print $3}'`
    solr_port=`echo ${line} | awk '{print $4}'`
    
    echo "$host_name 节点安装 tomcat_solr..."
    
    ssh -t root@${host_name} << EOF
mkdir -p /opt/tomcat_solr
mkdir -p /opt/solrhome
EOF
    scp -r -q tomcat/* $host_name:${tomcat_solr_path}
    scp -r -q solrhome/* $host_name:${solr_home_path}
    
    # 拷贝环境配置脚本以及启动脚本
    scp -q solr_install_config.sh $host_name:/opt/solr_install_config.sh
    
    echo "-----------------------配置 solrCloud----------------------"
    ssh -t root@${host_name} << EOF
sh /opt/solr_install_config.sh $host_name $solr_home_path $tomcat_solr_path $solr_port $4
rm -rf /opt/solr_install_config.sh
EOF
done

# 启动 solr 服务
cat $1 | while read line || [ -n "$line" ]
do
    host_name=`echo ${line} | awk '{print $1}'`
    tomcat_solr_path=`echo ${line} | awk '{print $3}'`
    
    echo "$host_name 节点启动 solr..."
    ssh -t root@${host_name} << EOF
sh ${tomcat_solr_path}/bin/startup.sh
EOF
done

# 删除 solr 安装文件
rm -rf solr-${solr_version}
rm -rf solrhome
rm -rf tomcat_solr

echo "-----------------------完成安装 solrCloud----------------------"