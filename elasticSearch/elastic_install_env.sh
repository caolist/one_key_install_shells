#!/bin/bash
if [[ $# < 4 ]] ; then
    echo "Usage: $0 1.es username 2.es home 3.data path(multi path: path1,path2,...) 4.log path"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 1.create es user
if [[ `cat /etc/passwd | grep -i ^$1: | wc -l` == 0 ]] ; then
    useradd -m -f -1 -s "/bin/bash" $1
passwd $1 << EOF
$1
$1
EOF
    echo "1.Es user:$1 is created."
fi

# 2.init folder
for data_path in `echo $3 | awk -F "," '{for(i=1;i<=NF;i++){print $i}}'`
do
    if [[ ! -e ${data_path} ]] ; then
        mkdir -p ${data_path}
    fi
    chown -R $1:$1 ${data_path}
    chmod -R 755 ${data_path}
done

if [[ ! -e $4 ]] ; then
    mkdir -p $4
fi

chown -R $1:$1 $4
chmod -R 755 $4

chown -R $1:$1 $2
chown -R $1:$1 $(dirname $4)

echo "ES data:$3, ES log:$4 are created."