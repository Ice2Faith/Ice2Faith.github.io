bak_host=$1
bak_user=$2
bak_password=$3

bak_db=$4
bak_file=$5

# 获取完整路径
bak_file=`realpath $bak_file`

echo recovery into ${bak_db} for host ${bak_host} use file ${bak_file} ...

chmod a+x ../lib/linux/mysql
echo [script exec]: lib/linux/mysql -h ${bak_host} -u${bak_user} -p${bak_password} ${bak_db} \< "${bak_file}"
../lib/linux/mysql -h ${bak_host} -u${bak_user} -p${bak_password} ${bak_db} < "${bak_file}"

echo recovery done into ${bak_db} for host ${bak_host} use file ${bak_file} .
