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
Устанвка роли для установки Docker:
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
