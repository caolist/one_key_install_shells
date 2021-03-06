#/bin/sh
# created by caoli 2018/07/27
# -----------------------------------------------------------------------------
# shell script for install MySQL (default version 5.7.23)
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

# 设置调试模式
# set -x

# 脚本参数解析
if [[ $# < 1 ]] ; then
    echo "Usage: $0 1.mysql version"
    echo "example:"
    echo "./mysql_install.sh 5.7.23-1.el7.x86_64"
    exit
fi

# tomcat 版本号
mysql_version=$1
echo $mysql_version

echo "-----------------------开始安装 mysql----------------------"

# 设置安装目录
mysql_ins_home=$PWD

# 设置安装日志文件
mysql_instlog="install_mysql.log"
mysql_instlog="`pwd`"/"$mysql_instlog"

# 检查是否安装 mysql，若安装，进行删除
echo "-----------------------检查是否已经安装 mysql----------------------"
for i in `rpm -qa | grep "mysql"`
do
    rpm -e --allmatches $i --nodeps
done

# 检查是否安装 mariadb，若安装，进行删除
echo "-----------------------检查是否已经安装 mariadb----------------------"
for i in $(rpm -qa | grep mariadb | grep -v grep)
do
    echo "删除 rpm -- > "$i
    rpm -e --nodeps $i
done

# 检查是否安装 postfix，若安装，进行删除
echo "-----------------------检查是否已经安装 postfix----------------------"
for i in $(rpm -qa | grep postfix | grep -v grep)
do
    echo "删除 rpm -- > "$i
    rpm -e --nodeps $i
done

# 安装 mysql
echo "-----------------------解压安装 mysql----------------------"
rpm -qa | grep "net-tools"
if test $? != 0 ;then
    rpm -ivh net-tools-2.0-0.22.20131004git.el7.x86_64.rpm
fi

tar -xf mysql-${mysql_version}.rpm-bundle.tar
rpm -ivh mysql-community-common-${mysql_version}.rpm
rpm -ivh mysql-community-libs-${mysql_version}.rpm
rpm -ivh mysql-community-libs-compat-${mysql_version}.rpm
rpm -ivh mysql-community-client-${mysql_version}.rpm
rpm -ivh mysql-community-server-${mysql_version}.rpm

# 检查是否成功安装 mysql
rpm -qa | grep "mysql"
if test $? != 0 ;then
    echo "mysql 安装失败"| tee $mysql_instlog
    exit 1
else
    echo "mysql 安装成功"| tee $mysql_instlog
fi

# 设置 mysql 参数
cd /etc/
echo "character_set_server=utf8" >> my.cnf
echo "lower_case_table_names=1" >> my.cnf

# 启动 mysql 服务
echo "-----------------------启动 mysql----------------------"
service mysqld start

# 检查 mysal 服务是否启动成功
echo "-----------------------检测 mysql 是否启动----------------------"
is_mysql_running=`service mysqld status | grep -i "running" | wc -l`

if test $is_mysql_running = "1" ; then
    echo 'mysql 服务正在运行'
else
    echo 'mysql 服务没有运行'
    exit
fi

# 配置 mysql
echo "-----------------------关闭 mysql----------------------"
service mysqld stop

cat /etc/my.cnf
sed -i '/mysqld/a\skip-grant-tables' /etc/my.cnf

echo "-----------------------重启 mysql----------------------"
service mysqld start

echo "-----------------------配置 mysql----------------------"
mysql -u root mysql -e "use mysql;update user set authentication_string=password('root') where user='root';flush privileges;"

cat /etc/my.cnf
sed -i '/skip-grant-tables/s/^/#/' /etc/my.cnf

mysql -u root -proot --connect-expired-password -e "SET PASSWORD = PASSWORD('root');"

# 允许远程连接
mysql -u root -proot -e "use mysql;update user set host = '%' where user ='root';"
mysql -u root -proot -e "flush privileges;"

# echo "-----------------------导入基础数据----------------------"
# cd $mysql_ins_home
# mysql -u root -proot -e "source ilog.sql"
# mysql -u root -proot -e "source phone_employee_info.sql"

# 删除 mysql 相关安装包
echo "-----------------------删除 mysql 安装包----------------------"
rm -rf mysql-community-*.rpm

echo "-----------------------完成安装 mysql----------------------"