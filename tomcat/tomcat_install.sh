#/bin/sh
# created by caoli 2018/08/08
# -----------------------------------------------------------------------------
# shell script for install tomcat (version 8.5.32)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 脚本参数解析
if [[ $# < 3 ]] ; then
    echo "Usage: $0 1.tomcat version 2.tomcat home 3.tomcat port"
    echo "example:"
    echo "./tomcat_install.sh 8.5.32 /opt/tomcat 8899"
    exit
fi

# tomcat 版本号
tomcat_version=$1
echo $tomcat_version

echo "-----------------------开始安装 tomcat----------------------"

# 解压安装 tomcat
tar -zxvf apache-tomcat-${tomcat_version}.tar.gz
if [[ ! -e $2 ]] ; then
    mkdir -p $2
fi
cp -R -f apache-tomcat-${tomcat_version}/* $2

# 修改 tomcat 端口号
sed -i "s/8080/$3/" $2/conf/server.xml

# 启动 tomcat 服务
sh $2/bin/startup.sh

# sleep 3

echo "-----------------------检测 tomcat 是否启动----------------------"

tomcatID=`ps -ef | grep tomcat | grep -v 'grep' | head -1 | awk '{print $2}'`
echo "The TomcatID is ${tomcatID}"

if [ $tomcatID ];then
    tomcatServerCode=`curl -I http://localhost:$3 > /tmp/tomcatStatus.txt`
    status=`cat /tmp/tomcatStatus.txt | head -1 | awk '{print $2}'`
    
    if [ $status -eq 200 ];then
        echo "tomcat 启动成功"
    else
        echo "tomcat 启动失败"
    fi
fi

# 删除 tomcat 安装文件
rm -rf apache-tomcat-${tomcat_version}

echo "-----------------------完成安装 tomcat----------------------"

