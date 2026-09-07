# %需要转义
esc_per=\%
esc_srp=\#

bak_file=$1

# 获取完整路径
bak_file=`realpath $bak_file`

# 在此处配置MySQL的连接信息
bak_host=
bak_user=
bak_password=
bak_db=

# 如果没有在此处配置连接信息，则从配置文件中读取
if [ "$bak_host"="" ];then
  bak_host=`head -n 1 ../conf/host.conf`
fi

if [ "$bak_user"="" ];then
  bak_user=`head -n 1 ../conf/user.conf`
fi

if [ "$bak_password"="" ];then
  bak_password=`head -n 1 ../conf/password.conf`
fi

if [ "$bak_db"="" ];then
  bak_db=`head -n 1 ../conf/database.conf`
fi



# add your table blow here like this

_rec_ret_path=`pwd`
cd ../sbin
chmod a+x ./recovery.sh
echo [script exec]: sbin/recovery.sh ${bak_host} ${bak_user} ${bak_password} ${bak_db} "${bak_file}"
./recovery.sh ${bak_host} ${bak_user} ${bak_password} ${bak_db} "${bak_file}"
cd $_rec_ret_path