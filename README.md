# parshyn-dima_microservices
parshyn-dima microservices repository

## Домашняя работа №16

Установка Docker
Для Fedora 33
```
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```
Установка docker, запуск службы, добавление пользователя в группу docker, чтобы запускать не из под root.

Установка Docker Compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```


Установка Docker Machine
```
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine
```

```
docker-machine version
```

Команды
```
docker ps
docker ps -a
docker images
```
Войти в контейнер, если выйти из контейнера, и заново запустить команду то создастся новый контейнер. Docker run каждый раз запускает новый контейнер
```
docker run -it ubuntu:18.04 /bin/bash
```
Если не указывать флаг --rm при запуске docker run, то после остановки контейнер вместе с содержимым остается на диске
Выводить список все контейнеров можно с фоматированием
```
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
```

Docker start & attach
start запускает остановленный(уже созданный) контейнер
attach подсоединяет терминал к созданному контейнеру
```
docker start <u_container_id>
docker attach <u_container_id>
```
Комбинация клавиш Ctrl+p, Ctrl+q позволяет выйти из контейнера и не завершить его работу

Docker run vs start
docker run = docker create + docker start + docker attach* (* - если есть опция -i)
docker create используется, когда не нужно стартовать контейнер сразу, в большинстве случаев используется docker run

Docker run
Через параметры передаются лимиты (cpu/mem/disk), ip, volumes
-i – запускает контейнер в foreground режиме ( docker attach )
-d – запускает контейнер в background режиме
-t создает TTY
```
docker run -it ubuntu:18.04 bash
docker run -dt nginx:latest
```

docker exec - Запускает новый процесс внутри контейнера
```
docker exec -it <u_container_id> bash
```

docker commit - Создает image из контейнера, контейнер при этом остается запущенным
```
docker commit <u_container_id> yourname/ubuntu-tmp-file
```
docker kill и stop - kill посылает SIGKILL, stop посылает SIGTERM
```
docker ps -q
<u_container_id>
docker kill $(docker ps -q)
<u_container_id>
```
docker system df - сколько место на диске занято образами
dcoker rm и rmi - rm - удалить остановленный контейнер (-f удалить запущенный), rmi - удаляет образ

Docker machine - своего рода vagrant, только создаёт виртуалки с docker engine. Поддерживает как VirtualBox, так и облачные провайдеры.
Создаём ВМ на YC
```
yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/id_rsa.pub
```
Установка docker. Необходимо заменить IP на действительный
```
docker-machine create \
--driver generic \
--generic-ip-address=<ПУБЛИЧНЫЙ_IP_СОЗДАНОГО_ВЫШЕ_ИНСТАНСА> \
--generic-ssh-user yc-user \
--generic-ssh-key ~/.ssh/id_rsa \
docker-host
```
Установил  Yandex.Cloud Docker machine driver
С помощью данного драйвера не нужно использовать cloud init и можно управлять ВМ. Например, с драйвером generic нельзя удалить или перезапустить ВМ.
Скачать docker-machine-driver-yandex и добавить в PATH
```
yc config list - необходимо значение folder id
export $YC_FOLDER_ID=folder id
docker-machine create --driver=yandex --yandex-folder-id=$YC_FOLDER_ID --yandex-cores=2 --yandex-memory=2 --yandex-nat=true --yandex-sa-key-file key.json docker-host
```

```
docker-machine ls - список хостов
```

```
docker-machine env <имя хоста> - экспортирует список переменных для локального докера
```
Долее выполнил
```
eval "$(docker-machine env <имя хоста>)
```
Если выполнить docker-machine ls, то будет видно, что в столбце ACTIVE стоит *, данный хост активен только в данной сессии. Можно открыть еще одно окно терминала и запустить второй экземпляр этого хоста.
Необходимо собрать образ (собираем его в docker-machine)
```
docker build -t reddit:latest .
```
Далее запустим контейнер
```
docker run --name reddit -d --network=host reddit:latest
```
При сборке образа возникли ошибки. В dockerfile удалил строку
```
RUN gem install bundler
```
а в предыдущую добавил
```
ruby-bundler
```
В файле mongodb.conf заменил /var/log/mongodb/mongod.log на /var/log/mongod.log
Теперь приложение доступно http://<ваш_IP_адрес>:9292

На Docker hub учетная запись уже была.
docker login - вводим логин и пароль от docker hub
Загрузить образ
```
docker tag reddit:latest <your-login>/otus-reddit:1.0
docker push <your-login>/otus-reddit:1.0
```
Проверка, в другой консоли выполнить
```
docker run --name reddit -d -p 9292:9292 <your-login>/otus-reddit:1.0
```

Задание со *  
**Terraform**  
Для развертывания приложения использовал Образ Container Optimized Image  
Docker-контейнер в Container Optimized Image описывается в спецификации (YAML-файле) spec.yml где указал, что необходимо использовать ранее созданный образ и пробросить порт 9292. Приложение будет доступно http://<Внешний _IP>:9292. Для запуска необходимо перейти в директорию infra/terraform
```
terraform init
terraform plan
terraform apply
```

**Ansible**  
ВМ развертываются в YC с помощью terraform. На основе данных terraform формируется файл hosts, используется шаблон hosts.tpl. Далее выполняется провиженер и запускаются плайбуки install_docker.yml, run_container.yml. Приложение будет доступно http://<Внешний _IP>:9292. Для запуска необходимо перейти в каталог infra/ansible/terraform
```
terraform init
terraform plan
terraform apply
```

**Packer**  
При сборке образа вначале выполняется провиженер, который запускает bash скрипт на локальной машине (ansible/inventory.sh) скрипт, создающий инвентори файл ansible/hosts. Далее запускается провиженер, который устанавливает docker. Запускать сборку необходимо из директории infra
```
packer build -var-file=packer/variables.json packer/docker.json
```
