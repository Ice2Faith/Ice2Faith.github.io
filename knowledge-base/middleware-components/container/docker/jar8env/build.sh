# build docker image by jar file
# author i2f

echo begin build image...
AppName=$1

if [ "${AppName}" == "" ];then
    echo find jar in current dir...
    AppName=`ls -f | grep .jar | grep -v .jar. | head -n 1`
    echo find AppName=${AppName}
fi

if [ "${AppName}" == "" ];then
   echo require least one argument of one jar,such test.jar
   exit 1
fi

ImageName=${AppName}.dimg

echo copy ${AppName} to ./app.jar
cp $AppName ./app.jar

echo clean old image ${ImageName}
docker rmi ${ImageName}

echo build for ${AppName}
docker build . -t ${ImageName}

echo clean ./app.jar
rm -rf ./app.jar

echo build done : ${AppName} --> ${ImageName}

RunSh=./run-${AppName}.sh
echo "docker run -d -p :8080 --name ${AppName} ${ImageName} --server.port=8080" > ${RunSh}
chmod a+rx ${RunSh}

DelImgSh=./rmi-${AppName}.sh
echo "ConId=\`docker ps -a | grep ${ImageName} | awk '{print \$1}'\`" > ${DelImgSh}
echo "docker stop \${ConId}" >> ${DelImgSh}
echo "docker rm \${ConId}" >> ${DelImgSh}
echo "docker rmi ${ImageName}" >> ${DelImgSh}
chmod a+rx ${DelImgSh}

EnterSh=./enter-${AppName}.sh
echo "ConId=\`docker ps -a | grep ${ImageName} | awk '{print \$1}'\`" > ${EnterSh}
echo "docker exec -it \${ConId} sh" >> ${EnterSh}
chmod a+rx ${EnterSh}

echo begin test image...
docker run --rm -p :8080 --name ${AppName} ${ImageName} --server.port=8080
