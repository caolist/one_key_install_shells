#/bin/sh
# created by caoli 2018/08/13
# -----------------------------------------------------------------------------
# shell script for install ilog
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 脚本参数解析
if [[ $# < 1 ]] ; then
    echo "Usage: $0 1.tomcat home 2.tomcat port"
    echo "example:"
    echo "./ilog_install.sh /opt/tomcat 8899"
    exit
fi

echo "-----------------------开始安装 ilog----------------------"

cp ilog.war $1/webapps

# todo 配置文件的拷贝


echo "-----------------------检测 tomcat 是否启动----------------------"

tomcatID=`ps -ef | grep tomcat | grep -v 'grep' | head -1 | awk '{print $2}'`
echo "The TomcatID is ${tomcatID}"
if [ $tomcatID ];then
    echo "tomcat 正在运行，稍后重启。"
    
    # 重启 tomcat 服务
    sh $1/bing/shutdown.sh
    sleep 10
    sh $1/bin/startup.sh
else
    echo "tomcat 没有运行，即将启动。"
    
    # 启动 tomcat 服务
    sh $1/bin/startup.sh
fi

sleep 60

tomcatID=`ps -ef | grep tomcat | grep -v 'grep' | head -1 | awk '{print $2}'`
echo "The TomcatID is ${tomcatID}"

if [ $tomcatID ];then
    tomcatServerCode=`curl -I http://localhost:$2/ilog/ > /tmp/tomcatStatus.txt`
    status=`cat /tmp/tomcatStatus.txt | head -1 | awk '{print $2}'`
    
    if [ $status -eq 200 ];then
        echo "ilog 启动成功"
    else
        echo "ilog 启动失败"
    fi
fi

echo "-----------------------完成安装 ilog----------------------"