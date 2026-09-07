# %需要转义
esc_per=\%
esc_srp=\#

bak_file=$1

# 获取完整路径
bak_file=`realpath $bak_file`

# add your table blow here like this

_recoverys_ret_path=`pwd`
cd ./mysql8/bin
chmod a+x ./rec.sh
./rec.sh ${bak_file}
cd $_recoverys_ret_path
