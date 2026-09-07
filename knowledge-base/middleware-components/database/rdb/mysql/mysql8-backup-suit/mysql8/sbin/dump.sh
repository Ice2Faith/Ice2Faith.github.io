bak_host=$1
bak_user=$2
bak_password=$3

bak_db=$4
bak_dir=$5

# 获取完整路径
bak_dir=`realpath $bak_dir`

bak_time=$(date "+%Y%m%d%H%M%S")

bak_path=${bak_dir}/${bak_db}/${bak_time:0:8}
mkdir -p ${bak_path}
bak_file=${bak_path}/${bak_db}-${bak_time}.sql

echo ------------ begin $(date "+%Y-%m-%d %H:%M:%S") ------------
echo dump database ${bak_db} to ${bak_file}...

chmod a+x ../lib/linux/mysqldump
echo [script exec]: lib/linux/mysqldump -h ${bak_host} -u${bak_user} -p${bak_password} --no-tablespaces --skip-extended-insert --single-transaction --quick ${bak_db} \> "${bak_file}"
../lib/linux/mysqldump -h ${bak_host} -u${bak_user} -p${bak_password} --no-tablespaces --skip-extended-insert --single-transaction --quick ${bak_db} > "${bak_file}"

echo dump done for dump database ${bak_db} to ${bak_file} .
echo ------------ end $(date "+%Y-%m-%d %H:%M:%S") ------------
