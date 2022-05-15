# ayden1st_microservices

### Лекция 15
#### 15.1
Создание и запуск контейнера
```
docker run <image>
```
Список запущенных контейнеров
```
docker ps
```
Запуск процесса в контейнере
```
docker exec -it <u_container_id> bash
```
Создание image
```
docker commit <u_container_id> yourname/ubuntu-tmp-file
```
#### 15.2
Docker image - это неизменяемый файл, содержащий исходный код, библиотеки, зависимости, инструменты и другие файлы, необходимые для запуска приложения. Docker container - это экземпляр image, содержащий новый слой доступный для записи и ряд настроек характерных для работающей машины, например NetworkSettings.
