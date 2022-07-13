yc compute instance create \
--name logging \
--zone ru-central1-a \
--network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
--ssh-key ~/.ssh/appuser.pub \
--memory 4

docker-machine create \
--driver generic \
--generic-ip-address=51.250.95.181 \
--generic-ssh-user yc-user \
--generic-ssh-key ~/.ssh/appuser \
logging

eval $(docker-machine env docker-host)

for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done


export USER_NAME=ayden1st
cd logging/fluentd/
docker build -t $USER_NAME/fluentd .
cd ../../docker/
docker-compose -f docker-compose-logging.yml up -d
docker-compose -f docker-compose.yml up -d

find_post
