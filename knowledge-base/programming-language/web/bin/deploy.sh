#!/bin/bash

AppName=dist
echo begin deploy ${AppName} ...

_p_now=$(date "+%Y%m%d%H%M%S")
_p_bak=${AppName}.${_p_now}
_p_bak_dir=backup.${AppName}

mkdir $AppName

echo backup ...
mkdir -p ${_p_bak_dir}
mv ${AppName} ${_p_bak_dir}/${_p_bak}

if [ -e "${AppName}.tar.gz" ]; then
    echo unpack ...
    tar -xzvf ${AppName}.tar.gz > /dev/null
elif [ -e "${AppName}.tgz" ]; then
         echo unpack ...
         tar -xzvf ${AppName}.tar.gz > /dev/null
else
    echo unzip ...
    unzip ${AppName}.zip -d ${AppName} > /dev/null
fi

echo verify directory...
if [ -d "${AppName}/${AppName}" ];then
    rm -rf tmp.${AppName}
    mv ${AppName} tmp.${AppName}
    mv tmp.${AppName}/${AppName} .
    rm -rf tmp.${AppName}
fi

echo done.
