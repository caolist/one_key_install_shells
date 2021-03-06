#/bin/sh
# created by caoli 2018/08/06
# -----------------------------------------------------------------------------
# shell script for install all software menu
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

ins_home=$PWD

[ -f /etc/init.d/functions ] && . /etc/init.d/functions

function read_config(){
    
    cat $1 | while read line || [ -n "$line" ]
    do
        echo ${line}
    done
}

function main_menu(){
cat << EOF
----------------------------------------------
|************请输入你的选择：[1-3]************|
----------------------------------------------
*   `echo -e "\033[36m 1)安装集群环境\033[0m"`
*   `echo -e "\033[36m 2)安装应用相关\033[0m"`
*   `echo -e "\033[36m 3)退出\033[0m"`
EOF
}

function lamp_menu(){
cat << EOF
----------------------------------------------
|************请输入你的选择：[1-6]************|
----------------------------------------------
*   `echo -e "\033[36m 1)安装 hadoop\033[0m"`
*   `echo -e "\033[36m 2)安装 zookeeper\033[0m"`
*   `echo -e "\033[36m 3)安装 kafka\033[0m"`
*   `echo -e "\033[36m 4)安装 elasticsearch\033[0m"`
*   `echo -e "\033[36m 5)安装 logstash\033[0m"`
*   `echo -e "\033[36m 6)安装 spark\033[0m"`
*   `echo -e "\033[36m 7)安装 flink\033[0m"`
*   `echo -e "\033[36m 8)安装 kafka-logs\033[0m"`
*   `echo -e "\033[36m 9)返回主菜单\033[0m"`
EOF
    read -p "####请输入安装集群环境菜单功能数字[1-8]：" num2
    # expr $num2 + 1 &>/dev/null  #这里加1，判断输入的是不是整数。
    # if [ $? -ne 0 ];then    #如果不等于零，代表输入不是整数。
    #     echo "###########################"
    #     echo "注意！！非法字符输入。"
    #     echo "请输入数字[1-9]:"
    #     echo "##########################"
    #     sleep 1
    # fi
    case $num2 in
        1)
            # action "安装 hadoop..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/hadoop_parms'`
            cd hadoop
            sh hadoop_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lamp_menu
        ;;
        2)
            # action "安装 zookeeper..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/zk_parms'`
            cd zookeeper
            sh zk_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lamp_menu
        ;;
        3)
            # action "安装 kafka..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/kafka_parms'`
            cd kafka
            sh kafka_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lamp_menu
        ;;
        4)
            # action "安装 elasticsearch..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/es_parms'`
            cd elasticsearch
            sh elastic_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lamp_menu
        ;;
        5)
            # action "安装 logstash..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/logstash_parms'`
            cd logstash
            sh logstash_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lamp_menu
        ;;
        6)
            # action "安装 spark..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/spark_parms'`
            cd spark
            sh spark_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lamp_menu
        ;;
        7)
            # action "安装 flink..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/flink_parms'`
            cd flink
            sh flink_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lamp_menu
        ;;
        8)
            # action "安装 kafka-logs..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/kafka-logs_parms'`
            cd kafka-logs
            sh kafka-logs_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lamp_menu
        ;;
        9)
            clear
            main_menu
        ;;
        *)
            clear
            echo -e "\033[31m输入错误，请重新输入数字[1-6]：\033[0m"
            lamp_menu
    esac
}

function lnmp_menu(){
cat << EOF
----------------------------------------------
|************请输入你的选择：[1-4]************|
----------------------------------------------
*   `echo -e "\033[36m 1)安装 mysql\033[0m"`
*   `echo -e "\033[36m 2)安装 tomcat\033[0m"`
*   `echo -e "\033[36m 3)安装 ilog\033[0m"`
*   `echo -e "\033[36m 4)返回主菜单\033[0m"`
EOF
    read -p "请输入安装应用相关菜单功能数字[1-4]：" num3
    # expr $num3 + 1 &>/dev/null  #这里加1，判断输入的是不是整数。
    # if [ $? -ne 0 ];then  #如果不等于零，代表输入不是整数。
    #     echo "###########################"
    #     echo "注意！！非法字符输入。"
    #     echo "请输入数字[1-4]:"
    #     echo "##########################"
    #     sleep 1
    # fi
    case $num3 in
        1)
            # action "安装 mysql..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/mysql_parms'`
            cd mysql
            sh mysql_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lnmp_menu
        ;;
        2)
            # action "安装 tomcat..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'install_parms/tomcat_parms'`
            cd tomcat
            sh tomcat_install.sh $CONFIG_VALUE
            cd $ins_home
            clear
            lnmp_menu
        ;;
        3)
            # action "安装 ilog..." /bin/true
            # sleep 2
            cd ilog
            sh ilog/ilog_install.sh
            cd $ins_home
            clear
            lnmp_menu
        ;;
        4)
            clear
            main_menu
        ;;
        *)
            clear
            echo -e "\033[31m输入错误，请重新输入数字[1-4]：\033[0m"
            lnmp_menu
    esac
}

clear
main_menu

while true ;do
    read -p "请输入主菜单上的数字[1-3]：" num1
    # expr $num1 + 1 &>/dev/null   #这里加1，判断输入的是不是整数。
    # if [ $? -ne 0 ];then   #如果不等于零，代表输入不是整数。
    #     echo "###########################"
    #     echo "注意！！非法字符输入。"
    #     echo "请输入数字[1-4]:"
    #     echo "##########################"
    #     sleep 1
    # fi
    case $num1 in
        1)
            clear
            lamp_menu
        ;;
        2)
            clear
            lnmp_menu
        ;;
        3)
            clear
            break
        ;;
        4)
            clear
            main_menu
        ;;
        *)
            clear
            echo -e "\033[31m输入错误，请重新输入数字[1-3]：\033[0m"
            main_menu
    esac
done