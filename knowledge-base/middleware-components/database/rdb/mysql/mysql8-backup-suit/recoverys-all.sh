# %需要转义
esc_per=\%
esc_srp=\#

bak_dir=$1

# 获取完整路径
bak_dir=`realpath $bak_dir`

# add your table blow here like this

_recoverys_ret_path=`pwd`
cd ./mysql8/bin
chmod a+x ./rec.sh

for i in `ls $bak_dir | grep .sql`
do
  bak_file=`realpath $bak_dir/$i`
  echo [script exec]: ./rec.sh ${bak_file}
  ./rec.sh ${bak_file}
done

cd $_recoverys_ret_path
