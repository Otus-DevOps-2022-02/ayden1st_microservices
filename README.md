# ayden1st_microservices

### Лекция 15
#### 15.1 Работа с контейнерами
Создание и запуск контейнера:
```
docker run <image>
```
Список запущенных контейнеров:
```
docker ps
```
Запуск процесса в контейнере:
```
docker exec -it <u_container_id> bash
```
Создание image из работающего контейнера:
```
docker commit <u_container_id> yourname/ubuntu-tmp-file
```
Удаление контейнеров и образов:
```
docker rm $(docker ps -a -q) # удалит все незапущенные контейнеры

docker rmi $(docker images -q)
```
#### 15.2 Задание со *
Docker image - это неизменяемый файл, содержащий исходный код, библиотеки, зависимости, инструменты и другие файлы, необходимые для запуска приложения. Docker container - это экземпляр image, содержащий новый слой доступный для записи и ряд настроек характерных для работающей машины, например NetworkSettings.

### Лекция 16
#### 16.1 Запуск контейнера на удаленной машине
> **WARNING**:Docker-machine deprecated.
Установка docker-machine на linux:
```
curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
```
Установка docker на удаленный хост:
```
docker-machine create \
--driver generic \
--generic-ip-address=<external_ip> \
--generic-ssh-user yc-user \
--generic-ssh-key ~/.ssh/appuser.pub \
docker-host
```
Сборка и запуск образа на удаленном хосте:
```
eval $(docker-machine env docker-host)
cd docker-momolith
docker build -t reddit:latest .
docker run --name reddit -d --network=host reddit:latest
```
Загрузка образа в DockerHub
```
docker login
docker tag reddit:latest <your-login>/otus-reddit:1.0
docker push <your-login>/otus-reddit:1.0
```

#### 16.2 Задание со *
Для использования провайдеров с зеркал нужно создать файл `vi ~/.terraformrc` и записать:
```
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```
Установка роли для установки Docker:
```
cd docker-monolith/infra/ansible
ansible-galaxy install -r requrements.yml -p ./roles
```
Создание образа с установленным докером:
```
cd ../packer
packer build -var-file=variables.json docker.json
```
Создание ВМ с использованием образа (колличество ВМ можно менять параметром **count_vm**):
```
cd docker-monolith/infra/terraform
terraform init
terraform apply
cd ./prod
terraform init -backend-config=./backend.conf
terraform apply
```
Запуск конетейнера на ВМ:
```
ansible-playbook playbooks/start_container.yml
```
### Лекция 17
#### 17.1 Создание и запуск связанных контейнеров
Build, создание сети reddit и запуск связанных контейнеров:
```
docker build -t ayden1st/post:1.0 ./post-py
docker build -t ayden1st/comment:1.0 ./comment
docker build -t ayden1st/ui:1.0 ./ui
docker pull mongo:latest
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post ayden1st/post:1.0
docker run -d --network=reddit --network-alias=comment ayden1st/comment:1.0
docker run -d --network=reddit -p 9292:9292 ayden1st/ui:1.0
```
#### 17.2 Задание со *
Запуск контейнеров с параметрами env, переопредящие параметры заданные в Dockerfile:
```
docker run -d --network=reddit --network-alias=post_db_new --network-alias=comment_db_new mongo:latest
docker run -d --network=reddit --network-alias=post_new \
  -e POST_DATABASE_HOST='post_db_new' \
  ayden1st/post:1.0
docker run -d --network=reddit --network-alias=comment_new \
  -e COMMENT_DATABASE_HOST='comment_db_new' \
  ayden1st/comment:1.0
docker run -d --network=reddit -p 9292:9292 \
  -e POST_SERVICE_HOST='post_new' \
  -e COMMENT_SERVICE_HOST='comment_new' \
  ayden1st/ui:1.0
```
#### 17.3 Задание со *
Оптимизированные образы в файлах Dockerfile.1
* Использованы alpine образы
* Очищается кеш установщиков pip, apk
```
REPOSITORY         TAG                IMAGE ID       CREATED              SIZE
ayden1st/ui        3.0                db2ad76145e1   About a minute ago   91.6MB
ayden1st/post      2.0                ca124214c3be   19 minutes ago       64.8MB
ayden1st/comment   2.0                9c9df1e44931   44 minutes ago       89MB
ayden1st/ui        2.0                d022e4e0dea8   About an hour ago    432MB
ayden1st/post      1.0                12a27f67be5d   2 hours ago          121MB
ayden1st/ui        1.0                cfbc38f21173   3 hours ago          762MB
ayden1st/comment   1.0                a4b332da83e1   3 hours ago          759MB
```
Build и запуск коннтейнеров с оптимизированными образами:
```
docker build -t ayden1st/post:2.0 -f ./post-py/Dockerfile.1 ./post-py
docker build -t ayden1st/comment:2.0 -f ./comment/Dockerfile.1 ./comment
docker build -t ayden1st/ui:3.0 -f ./ui/Dockerfile.1 ./ui
docker run -d --network=reddit --network-alias=post_db \
--network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post ayden1st/post:2.0
docker run -d --network=reddit --network-alias=comment ayden1st/comment:2.0
docker run -d --network=reddit -p 9292:9292 ayden1st/ui:3.0
```
#### 17.4 Использование volume
Создание volume и запуск контейнеров с его использованием:
```
docker volume create reddit_db
docker run -d --network=reddit --network-alias=post_db \
--network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post ayden1st/post:1.0
docker run -d --network=reddit --network-alias=comment ayden1st/comment:1.0
docker run -d --network=reddit -p 9292:9292 ayden1st/ui:2.0
```
Остановка и удаление контейнеров:
```
docker kill $(docker ps -q)
docker container prune
```
### Лекция 18
#### Docker и сети
Запуск контейнеров с несколькими сетями:
```
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
docker run -d --network=front_net -p 9292:9292 --name ui ayden1st/ui:1.0
docker run -d --network=back_net --name comment ayden1st/comment:1.0
docker run -d --network=back_net --name post ayden1st/post:1.0
docker run -d --network=back_net --name mongo_db \
  --network-alias=post_db --network-alias=comment_db mongo:latest
docker network connect front_net post
docker network connect front_net comment
```
#### 18.2 Docker-compose
Добавлены переменные окружения:
* Логин пользователя в DockerHub
* Порт приложения
* Версия приложений
* Имя проекта
Базовое имя проекта в docker-compose берется из имени папки в которой находится файл docker-compose. Изменить можно задав переменную env COMPOSE_PROJECT_NAME или запустив docker-compose с флагом -p <NAME>.
#### 18.3 Задание со *
Файл docker-compose.override.yml добавлены:
* Монтирование папки приложения в контейнер (работает на локальной машине)
* Добавлена опция command переопределяющая запуск puma с отличными от образа дополнительными параметрами `--debug -w 2`
