# %需要转义
esc_per=\%
esc_srp=\#

bak_dir=./db_dump

# 获取完整路径
bak_dir=`realpath $bak_dir`

_backups_ret_path=`pwd`
cd ./mysql8/bin
chmod a+x ./dump.sh

./dump.sh "${bak_dir}"

cd $_backups_ret_path