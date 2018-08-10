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
|*******Please Enter Your Choice:[1-4]*******|
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
|*******Please Enter Your Choice:[1-4]*******|
----------------------------------------------
*   `echo -e "\033[35m 1)http install\033[0m"`
*   `echo -e "\033[35m 2)mysql install\033[0m"`
*   `echo -e "\033[35m 3)php install\033[0m"`
*   `echo -e "\033[35m 4)return main menu\033[0m"`
EOF
    read -p "####please input second_lamp optios[1-4]: " num2
    expr $num2 + 1 &>/dev/null  #这里加1，判断输入的是不是整数。
    if [ $? -ne 0 ];then    #如果不等于零，代表输入不是整数。
        echo "###########################"
        echo "Waing !!!,input error   "
        echo "Please enter choose[1-4]:"
        echo "##########################"
        exit 1
    fi
    case $num2 in
        1)
            action "Installed httpd..." /bin/true
            sleep 2
            lamp_menu
        ;;
        2)
            action "Installed MySQL..." /bin/true
            sleep 2
            lamp_menu
        ;;
        3)
            action "Installed PHP..." /bin/true
            sleep 2
            lamp_menu
        ;;
        4)
            clear
            main_menu
        ;;
        *)
            clear
            echo
            echo -e "\033[31mYour Enter the wrong,Please input again Choice:[1-4]\033[0m"
            lamp_menu
    esac
}

function lnmp_menu(){
cat << EOF
----------------------------------------------
|*******Please Enter Your Choice:[1-4]*******|
----------------------------------------------
*   `echo -e "\033[35m 1)安装 mysql\033[0m"`
*   `echo -e "\033[35m 2)安装 tomcat\033[0m"`
*   `echo -e "\033[35m 3)安装 ilog\033[0m"`
*   `echo -e "\033[35m 4)返回主菜单\033[0m"`
EOF
    read -p "please input second_lnmp options[1-4]: " num3
    expr $num2 + 1 &>/dev/null  #这里加1，判断输入的是不是整数。
    if [ $? -ne 0 ];then  #如果不等于零，代表输入不是整数。
        echo
        echo "Please enter a integer"
        exit 1
    fi
    case $num3 in
        1)
            action "Installed mysql..." /bin/true
            sleep 2
            lnmp_menu
        ;;
        2)
            # action "Installed tomcat..." /bin/true
            # sleep 2
            CONFIG_VALUE=`read_config 'tomcat_config'`
            echo $CONFIG_VALUE
            cd tomcat
            sh tomcat_install.sh $CONFIG_VALUE
            clear
            lnmp_menu
        ;;
        3)
            action "Installed ilog..." /bin/true
            sleep 2
            clear
            lnmp_menu
        ;;
        4)
            clear
            main_menu
        ;;
        *)
            clear
            echo
            echo -e "\033[31mYour Enter the wrong,Please input again Choice:[1-4]\033[0m"
            lnmp_menu
    esac
}

clear
main_menu

while true ;do
    read -p "##please Enter Your first_menu Choice:[1-4]" num1
    expr $num1 + 1 &>/dev/null   #这里加1，判断输入的是不是整数。
    if [ $? -ne 0 ];then   #如果不等于零，代表输入不是整数。
        echo "----------------------------"
        echo "|      Waring!!!           |"
        echo "|Please Enter Right Choice!|"
        echo "----------------------------"
        sleep 1
    fi
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
            echo -e "\033[31mYour Enter a number Error,Please Enter again Choice:[1-4]: \033[0m"
            main_menu
    esac
done