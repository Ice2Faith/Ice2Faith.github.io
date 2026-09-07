@echo off
echo minio server starting...
::set MINIO_ACCESS_KEY=root
::set MINIO_SECRET_KEY=ltb12315
set MINIO_ROOT_USER=root
set MINIO_ROOT_PASSWORD=ltb12315
minio.exe server .\minio-data --console-address ":9001" --address ":9000"

