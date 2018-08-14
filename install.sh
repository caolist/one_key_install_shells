#/bin/sh
# created by caoli 2018/08/06
# -----------------------------------------------------------------------------
# shell script for install all software menu
# -----------------------------------------------------------------------------

if [[ "root" != `whoami` ]] ; then
    echo "请使用 root 用户执行!"
    exit
fi

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
|************请输入你的选择：[1-4]************|
----------------------------------------------
*   `echo -e "\033[35m 1)安装集群环境\033[0m"`
*   `echo -e "\033[35m 2)安装应用相关\033[0m"`
*   `echo -e "\033[35m 3)退出\033[0m"`
*   `echo -e "\033[35m 4)返回主菜单\033[0m"`
EOF
}

function lamp_menu(){
cat << EOF
----------------------------------------------
|************请输入你的选择：[1-5]************|
----------------------------------------------
*   `echo -e "\033[35m 1)安装 zookeeper\033[0m"`
*   `echo -e "\033[35m 2)安装 kafka\033[0m"`
*   `echo -e "\033[35m 3)安装 logstash\033[0m"`
*   `echo -e "\033[35m 4)安装 elasticSearch\033[0m"`
*   `echo -e "\033[35m 5)返回主菜单\033[0m"`
EOF
    read -p "####请输入安装集群环境菜单功能数字[1-5]：" num2
    # expr $num2 + 1 &>/dev/null  #这里加1，判断输入的是不是整数。
    # if [ $? -ne 0 ];then    #如果不等于零，代表输入不是整数。
    #     echo "###########################"
    #     echo "注意！！非法字符输入。"
    #     echo "请输入数字[1-5]:"
    #     echo "##########################"
    #     sleep 1
    # fi
    case $num2 in
        1)
            # action "安装 zookeeper..." /bin/true
            # sleep 2
            cd zookeeper
            CONFIG_VALUE=`read_config 'install_parms/zk_parms'`
            sh zk_install.sh $CONFIG_VALUE
            cd ..
            clear
            lamp_menu
        ;;
        2)
            # action "安装 kafka..." /bin/true
            # sleep 2
            cd kafka
            CONFIG_VALUE=`read_config 'install_parms/kafka_parms'`
            sh kafka_install.sh $CONFIG_VALUE
            cd ..
            clear
            lamp_menu
        ;;
        3)
            # action "安装 logstash..." /bin/true
            # sleep 2
            cd logstash
            CONFIG_VALUE=`read_config 'install_parms/logstash_parms'`
            sh logstash_install.sh $CONFIG_VALUE
            cd ..
            clear
            lamp_menu
        ;;
        4)
            # action "安装 elasticSearch..." /bin/true
            # sleep 2
            cd elasticSearch
            CONFIG_VALUE=`read_config 'install_parms/es_parms'`
            sh elastic_install.sh $CONFIG_VALUE
            cd ..
            clear
            lamp_menu
        ;;
        5)
            clear
            main_menu
        ;;
        *)
            clear
            echo -e "\033[31m输入错误，请重新输入数字[1-5]：\033[0m"
            lamp_menu
    esac
}

function lnmp_menu(){
cat << EOF
----------------------------------------------
|************请输入你的选择：[1-4]************|
----------------------------------------------
*   `echo -e "\033[35m 1)安装 mysql\033[0m"`
*   `echo -e "\033[35m 2)安装 tomcat\033[0m"`
*   `echo -e "\033[35m 3)安装 ilog\033[0m"`
*   `echo -e "\033[35m 4)返回主菜单\033[0m"`
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
            cd mysql
            sh mysql_install.sh
            cd ..
            clear
            lnmp_menu
        ;;
        2)
            # action "安装 tomcat..." /bin/true
            # sleep 2
            cd tomcat
            CONFIG_VALUE=`read_config 'install_parms/tomcat_parms'`
            sh tomcat_install.sh $CONFIG_VALUE
            cd ..
            clear
            lnmp_menu
        ;;
        3)
            # action "安装 ilog..." /bin/true
            # sleep 2
            cd ilog_app
            sh ilog_app/ilog_install.sh
            cd ..
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
    read -p "##请输入主菜单上的数字[1-4]：" num1
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
            echo -e "\033[31m输入错误，请重新输入数字[1-4]：\033[0m"
            main_menu
    esac
done