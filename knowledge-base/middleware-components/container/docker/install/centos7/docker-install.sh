# install docker for syetm
# author i2f

echo uninstall old docker
yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

echo install drivers
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

echo set repository
yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

echo install docker community
yum install docker-ce docker-ce-cli containerd.io

echo set autorun-boot
systemctl enable docker

echo start docker
systemctl start docker

echo add mirrors of images
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://mirror.aliyuncs.com",
    "https://mirror.baidubce.com",
    "https://docker.m.daocloud.io",
    "https://hub-mirror.c.163.com",
    "https://mirror.tuna.tsinghua.edu.cn",
    "https://2a6bf1988cb6428c877f723ec7530dbc.mirror.swr.myhuaweicloud.com",
    "https://your_preferred_mirror",
    "https://dockerhub.icu",
    "https://docker.registry.cyou",
    "https://docker-cf.registry.cyou",
    "https://dockercf.jsdelivr.fyi",
    "https://docker.jsdelivr.fyi",
    "https://dockertest.jsdelivr.fyi",
    "https://dockerproxy.com",
    "https://docker.m.daocloud.io",
    "https://docker.nju.edu.cn",
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://docker.mirrors.ustc.edu.cn",
    "https://mirror.iscas.ac.cn",
    "https://docker.rainbond.cc"
  ]
}

EOF

systemctl daemon-reload
systemctl restart docker

echo test by hello-world
docker search hello-world
docker pull hello-world
docker run --rm hello-world

echo docker has installed.


echo install docker-compose
curl -L https://github.com/docker/compose/releases/download/v2.30.2/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose

docker-compose --version