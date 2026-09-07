echo minio server starting...
# MINIO_ACCESS_KEY=root
# MINIO_SECRET_KEY=ltb12315
chmod a+x ./minio
export MINIO_ROOT_USER=root
export MINIO_ROOT_PASSWORD=ltb12315
nohup ./minio server ./minio-data --console-address ":9001" --address ":9000" 2>&1 > minio.log &
sleep 2
echo done.