# %需要转义
esc_per=\%
esc_srp=\#

bak_dir=./db_backup

# 获取完整路径
bak_dir=`realpath $bak_dir`

# 表列表文件
_tables_list_file=`pwd`/tables.txt

_backups_ret_path=`pwd`
cd ./mysql8/bin
chmod a+x ./bak.sh

# load from tables.txt
# add your table names into tables.txt
# every line is an table
for line in `cat $_tables_list_file`
do
  ./bak.sh $line "${bak_dir}"
done

cd $_backups_ret_path