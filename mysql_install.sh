#/bin/sh
# created by caoli 2018/07/27
# -----------------------------------------------------------------------------
# shell script to install MySQL (default version mysql-community-5.7.9)
# -----------------------------------------------------------------------------

#设置调试模式
set -x

echo "-----------------------开始安装 mysql----------------------"

# 设置安装目录
mysql_ins_home=$PWD

# 设置安装日志文件
mysql_instlog="install_mysql.log"
mysql_instlog="`pwd`"/"$mysql_instlog"

# 检查是否安装 mysql，若安装，进行删除
for i in `rpm -qa | grep "mysql"`
do
	rpm -e --allmatches $i --nodeps
done

# 检查是否安装 mariadb，若安装，进行删除
for i in $(rpm -qa | grep mariadb | grep -v grep)
do
	echo "删除 rpm -- > "$i
	rpm -e --nodeps $i
done

# 检查是否安装 postfix，若安装，进行删除
for i in $(rpm -qa | grep postfix | grep -v grep)
do
	echo "删除 rpm -- > "$i
	rpm -e --nodeps $i
done

# 安装 mysql
rpm -qa | grep "net-tools"
if test $? != 0 ;then
	rpm -ivh net-tools-2.0-0.22.20131004git.el7.x86_64.rpm
fi

tar -xvf mysql-5.7.9-1.el7.x86_64.rpm-bundle.tar
rpm -ivh mysql-community-common-5.7.9-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.9-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-compat-5.7.9-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-5.7.9-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-5.7.9-1.el7.x86_64.rpm

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
service mysqld start

# 检查 mysal 服务是否启动成功
is_mysql_running=`service mysqld status | grep -i "running" | wc -l`

if test[ $is_mysql_running = "1" ] ; then
	echo 'mysql 服务正在运行'
else
	echo 'mysql 服务没有运行，请检查'
	exit
fi

# 配置 mysql
service mysqld stop

cat /etc/my.cnf
sed -i '/mysqld/a\skip-grant-tables' /etc/my.cnf

service mysqld start

mysql -u root mysql -e "use mysql;"
mysql -u root mysql -e "update user set authentication_string=password('root') where user='root';"
mysql -u root mysql -e "flush privileges;"

cat /etc/my.cnf
sed -i '/skip-grant-tables/s/^/#/' /etc/my.cnf

mysql -u root -proot --connect-expired-password -e "SET PASSWORD = PASSWORD('root');"
mysql -u root -proot -e "use mysql;"
mysql -u root -proot -e "update user set host = '%' where user ='root';"

# 删除 mysql 相关安装包
cd $mysql_ins_home
rm -rf mysql-community-*.rpm

echo "-----------------------完成安装 mysql----------------------"