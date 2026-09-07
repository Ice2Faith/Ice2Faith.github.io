#!/bin/bash

KEEP_COUNT=10

_p_name=dist
_p_root_path=.

echo clean begin ...

if [ "$_p_name" == "" ];
then
    _p_name=$(basename $(pwd))
fi

echo clean name : $_p_name

_p_path=${_p_root_path}/backup.${_p_name}
echo clean path : $_p_path

_p_count=$(ls -t ${_p_path} | wc -l)
echo all count : $_p_count
echo keep count : $KEEP_COUNT

_p_del_count=$(($_p_count - $KEEP_COUNT))
echo clean count : $_p_del_count

if [ $_p_del_count -gt 0 ]
then
    for item in $(ls -t ${_p_path} | tail -n ${_p_del_count}); do
        echo del: ${_p_path}/${item}
        rm -r ${_p_path}/${item}
    done
else
  echo not need clean item.
fi

echo clean done.

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
