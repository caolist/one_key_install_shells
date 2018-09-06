#!/bin/bash

if [[ $# < 2 ]] ; then
	echo "Usage: $0 1.jvm config file path 2.jvm size"
	exit
fi

if [[ -f $1 ]] ; then
    sed -i -e "/^-Xms/Ic\-Xms$2" -e "/^-Xmx/Ic\-Xmx$2" $1
else
cat << EOF >> $1
-Xms$2
-Xmx$2
EOF

fi