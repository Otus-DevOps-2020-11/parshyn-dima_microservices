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

## Домашняя работа №17

Скачал тестовое приложение разбитое на микросервисы.
В каждом каталоге создал Dockerfile.
Произвел сборку образов docker на основе dockerfile, и запустил приложение. Данные действия производятся на docker-machine, созданной в YC.
Команды для сборки

```
export YC_FOLDER_ID=<значение>
docker-machine create --driver=yandex --yandex-folder-id=$YC_FOLDER_ID --yandex-cores=2 --yandex-memory=2 --yandex-nat=true --yandex-sa-key-file key.json docker-host
docker-machine env docker-host
eval $(docker-machine env docker-host)
docker pull mongo:latest
docker build -t dvparshin/post:1.0 ../src/post-py
docker build -t dvparshin/comment:1.0 ../src/comment
docker build -t dvparshin/ui:1.0 ../src/ui
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post dvparshin/post:1.0
docker run -d --network=reddit --network-alias=comment dvparshin/comment:1.0
docker run -d --network=reddit -p 9292:9292 dvparshin/ui:1.0
```

Задание со *
Задал при сборке свои переменные
```
docker run -d --network=reddit --network-alias=new_post_db --network-alias=new_comment_db mongo:latest
docker run -d --network=reddit --network-alias=post --env POST_DATABASE_HOST=new_post_db dvparshin/post:1.0
docker run -d --network=reddit --network-alias=comment --env COMMENT_DATABASE_HOST=new_comment_db dvparshin/comment:1.0
docker run -d --network=reddit -p 9292:9292 dvparshin/ui:1.0
```

Собрал образ для **ui** на базе Alpine. Для **comment** собрал образ на основе ruby:2.4-alpine3.7. Заменил ADD на COPY.
```
REPOSITORY          TAG             IMAGE ID       CREATED        SIZE
dvparshin/ui        1.0             5b8cf2f1a361   20 hours ago   265MB
dvparshin/comment   1.0             887ab92aec40   20 hours ago   224MB
dvparshin/post      1.0             21bed8d42cfe   20 hours ago   110MB
```
## Домашняя работа №18

### Docker, работа с сетью

ДЗ выполнял по методичке.
Все работы проводил на docker-machine, созданной в YC.
Запустил docker контейнеры с различными типами сети (none, host, dridge).

```
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
docker-machine ssh docker-host ifconfig
```

```
docker run --network host -d nginx
```
Запустил данный контейнер 4 раза, первый раз контейнер запустился успешно. Остальные три не запустились, так порт 80 уже занят.
Так как контейнеры общаются между собой по dns именам, то им необходимо назначить сетевые псевдонимы.

```
docker kill $(docker ps -q)
ocker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post dvparshin/post: 1.0
docker run -d --network=reddit --network-alias=comment dvparshin/comment:1.0
docker run -d --network=reddit -p 9292:9292 dvparshin/ui:1.0
```

Далее разбил сети на два сегмента.
```
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
```
Docker при инициализации контейнера может подключить к нему только 1 сеть. Поэтому подключил контейнеры к другой сети
```
docker network connect front_net post
docker network connect front_net comment
```

### Docker-compose

Установил docker-compose, создал docker-compose.yml
Добавил в файл конфига сети (back_net, front_net).
Параметризовал следующие параметры
 - Порт приложения
 - Порт приложения в контейнере
 - Тэги
 - IP подсетей

Добавил в файл env параметр **COMPOSE_PROJECT_NAME** с помощью которого можно задать имя проекта.
Создал файл docker-compose.override.yml. Для проверки необходимо выполнить
```
docker-compose kill
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

```
      Name                   Command             State           Ports
-------------------------------------------------------------------------------
reddit_comment_1   puma --debug -w 2             Up
reddit_post_1      python3 post_app.py           Up
reddit_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
reddit_ui_1        puma --debug -w 2             Up      0.0.0.0:9292->9292/tcp
```

## Домашняя работа №20

Для создания ВМ GitLab написал terraform файл и взял готовую роль ansible   geerlingguy /ansible-role-gitlab . Столкнулся с проблемой, что если указать в terraform зарезервированный внешний IP, то создание ВМ заканчивается ошибкой и сообщением, что это баг и необходимо обратиться в поддержку )
Поэтому развернул ВМ руками и с помощью роли ansible установил GitLab, выбрал этот вариант, так как есть свой домен и хотелось сразу при установке GitLab сформировать letsencrypt сертификат. Если сертификат не важен, то можно использовать terraform+ansible, внеся изменения в gitlab/ansible/roles/gitlab/defaults/main.yml. На выходе будет ВМ с самоподписанным сертификатом.
```
gitlab_redirect_http_to_https: "false"
```
и
```
gitlab_create_self_signed_cert: "true"
```
Также в gitlab/ansible/ansible.cfg необходимо
```
inventory = inventory.yml
заменить на
inventory = hosts
```
Файл hosts создаётся из шаблона в terraform.
Можно конечно было создать bash с командами YC CLI, который будет создавать ВМ c зарезервированным IP и запускать ansible роль.

Сервер доступен по адресу https://gitlab.dparshin.ru/
Создал группу homework и проект example.
Добавил удаленный репозиторий на gitlab
```
git remote add gitlab git@gitlab.dparshin.ru:homework/example.git
git push gitlab gitlab-ci-1
```

Создал ВМ в YC, в качестве образа выбрал Container Optimized Image 2.0.3, зашел по ssh
```
docker run -d --name gitlab-runner --restart always -v /srv/gitlab-runner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest
```

```
docker exec -it gitlab-runner gitlab-runner register \
--url https://gitlab.dparshin.ru/ \
--non-interactive \
--locked=false \
--name DockerRunner \
--executor docker \
--docker-image alpine:latest \
--registration-token RH8GKkjCT8vft7jAEoMH \
--tag-list "linux,xenial,ubuntu,docker" \
--run-untagged
```

Shell runner
```
sudo curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
sudo chmod +x /usr/local/bin/gitlab-runner
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```

```
gitlab-runner register \
--url https://gitlab.dparshin.ru/ \
--non-interactive \
--locked=false \
--name ShellRunner \
--executor shell \
--registration-token yckn_mLV7koPvedfqYwZ \
--tag-list "app-shell" \
--run-untagged
```
Добавил проект
```
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m "Add reddit app"
git push gitlab gitlab-ci-1
```

### Задание со *
### Запуск reddit в контейнере

Столкнулся с проблемой, что dind (docker in docker) завершался ошибкой, исправил заменой в config.toml privileged = false на privileged = true
```
sudo vi /srv/gitlab-runner/config/config.toml
```
Для сборки приложения использовал ВМ на основе Container Optimized Image, там предустановлен docker и docker-compose. На данной ВМ установил и зарегистрировал два gitlab runner (docker и shell). Первый собирает docker образ, с помощью второго происходит деплой приложения из созданного образа.

Настроил работу GitLab на работу со своим репозиторием образов. То есть при коммите создаётся докер образ, которому присваивается тэг сокращенного хэша коммита и тэг latest. Также пробовал работу с docker hub, для этого в настройках ci/cd проекта - Variables добавил переменные (DOCKER_REGISTRY_PASS, DOCKER_REGISTRY_USER). Для сборки образа использовал Dockerfile и docker runner.

Для сборки приложения использовал docker-compose файл и shell runner.
Как при развертывании приложения назначать ВМ нужную dns запись я не понял.

### Автоматизация развёртывания GitLab Runner

Найденная роль отрабатывает, однако зарегистрированный runner в gitlab отображается с восклицательным знаком. Для работы роли создал Access Tokens (Иконка профиля - edite profile - access tokens). В файле terraform/main.tf в строке запуска плайбука необходимо удказать токены gitlab
```
ansible-playbook ../ansible/provision.yml -e "GITLAB_API_TOKEN= GITLAB_REGISTRATION_TOKEN="
```
Проще всего наверное настроить установку и регистрацию раннеров через bash скрипт

Настройка оповещений в Slack

### Slack Notifications Service
Оповещения в slack настроил по мануалу с официальной странице gitlab

![Screen](https://raw.githubusercontent.com/parshyn-dima/Screenshot/main/Screenshot%20from%202021-03-17%2012-09-55.png)

## Домашняя работа №22

Создал ВМ с помощью docker-machine
```
docker-machine create --driver=yandex --yandex-folder-id=$YC_FOLDER_ID --yandex-image-id=fd87uq4tagjupcnm376a --yandex-cores=2 --yandex-memory=2 --yandex-nat=true --yandex-sa-key-file key.json docker-host
docker-machine env docker-host
eval $(docker-machine env docker-host)
```
Запускаем контейнер с prometheus
```
docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus
```
Остановил контейнер
```
docker stop prometheus
```
Создал dockerfile, который создаёт контейнер prometheus и передает в него файл конфигурации Prometheus.yml
В данном добавлены таргеты микросервисов нашего приложения (ui, comment)
Столкнулся с проблемой, ранее в файле env переменная определяющая имя пользователя называлась USERNAME, в результате сборка образов заканчивалась ошибкой. Изменил на USER_NAME.
Перешел в каталог monitoring/prometheus. Собрал образ.
```
export USER_NAME=dvparshin
docker build -t $USER_NAME/prometheus .
```
Из корня проекта собрал остальные образы
```
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```
Переходим в docker/docker-monolith
```
docker-compose up -d
```
Добавил конфиг контейнера prometheus  в docker-compose.yml
```
docker-compose up -d
```
Для мониторинга ОС и БД используют Node exporter, приложение которое собирает метрики в нужном формате для prometheus.
Добавил описание контейнера в docker-compose.yml. Чтобы указать prometheus за какими сервисами следить, инфу нужно добавить в prometheus.yml. После этого нужно пересобрать образ prometheus и перезапустить compose
```
docker build -t $USER_NAME/prometheus .
```

```
docker-compose down
docker-compose up -d
```
Проверить, что node exporter добавился можно http://<IP>:9090/targets
### Задание со *

**мониторинг MongoDB**

Для мониторинга mongo использовал percona/mongodb-exporter. Для создания своего dockerfile использовал вот этот bitnami-docker-mongodb-exporter.
Dockerfile разместил monitoring/mongodb_exporter, собрал образ и запушил его, добавил конфиг в
prometheus.yml (После этого пришлось пересобрать образ prometheus)
```
- job_name: 'mongo'
    static_configs:
      - targets:
        - 'mongo-exporter:9216'
```
docker-compose.yml
```
mongo-exporter:
    image: ${USER_NAME}/mongodb-exporter:latest
    environment:
      - MONGODB_URI=mongodb://post_db:27017
    networks:
      - front_net
      - back_net
    ports:
      - 9216:9216
    depends_on:
      - post_db
```

**Добавить в Prometheus мониторинг сервисов comment, post, ui с помощью blackbox экспортера**

Аналогично mongo-exporter использовал prometheus/blackbox_exporter. Для создания своего dockerfile использовал вот этот bitnami-docker-blackbox-exporter.   Dockerfile разместил в monitoring/blackbox_exporter, собрал образ и запушил его, добавил конфиг в
prometheus.yml (После этого пришлось пересобрать образ prometheus)
```
- job_name: 'blackbox_http'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - comment:9292/healthcheck
        - post:5000/healthcheck
        - ui:9292/healthcheck
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 'blackbox-exporter:9115'
```
docker-compose.yml
```
blackbox-exporter:
    image: ${USER_NAME}/blackbox-exporter:latest
    networks:
      - front_net
      - back_net
    user: root
    ports:
      - 9115:9115
```

## Домашняя работа №23

Создал окружение
```
export YC_FOLDER_ID=<ID>
docker-machine create --driver=yandex --yandex-folder-id=$YC_FOLDER_ID --yandex-image-id=fd87uq4tagjupcnm376a --yandex-cores=2 --yandex-memory=2 --yandex-nat=true --yandex-sa-key-file key.json docker-host
docker-machine env docker-host
eval $(docker-machine env docker-host)
```
Разлелил docker-compose.yml, все что касается мониторинга вынес в docker-compose-monitoring.yml.
Добавил в проект cAdvisor.
Добавил в проект Grafana. Добавил дашборды по инструкции.
Добавил в проект alertmanager, настроил отправку оповещений в slack.

### Задание со *

1. Дополнил Makefile
2. Включил экспериментальный режим в docker, чтобы напрямую отдавать метрики в prometheus, а не через node exporter.

Для этого подключился к ВМ
```
docker-machine ssh docker-host
```
Создал файл конфигурации
```
sudo vi /etc/docker/daemon.json

{
  "metrics-addr" : "10.0.1.1:9323",
  "experimental" : true
}
```
10.0.1.1 - первый адрес в сети front_net, можно было взять и back_net, контейнер prometheus смотрит и туда и туда.
Рестарт службы docker
```
sudo systemctl restart docker
```
Если данный метод сравнивать с Cadvisor, то Cadvisor лучше, так как имеет намного больше метрик. Дашбордов для мониторинга docker в этом режиме мало. Найденный дашборд сохранил в файл docker-engine-metrics_rev3.json

3. Добавил telegraf, метрик собирается мало. Я так и не нашел дашборда для docker.
4. В конфиг alermanager добавил отправку на email, через почту gmail. Главное в настройках профиля google - безопасность - Небезопасные приложения разрешены (включить)
Ссылка на DockerHub https://hub.docker.com/u/dvparshin

## Домашняя работа №25

Новая версия приложения из методички не работает! Использовал ту же версию с которой и работали ранее.  
В docker_build.sh изменил тэг на logging, также заменил в .env  
Драйвер docker-machine для YC использовал уже давно.  
Создал docker-compose-logging.yml для развертывания стека EFK  
Создал Dockerﬁle и конфигурацию для Fluentd  
Настроил отправку логов во Fluentd для сервиса post (структурированные логи)  
Настроил индекс для Kibana потыкал поиск по логам.  
Добавил фильтр во Fluentd для сервиса post  
Настроил отправку логов во Fluentd для сервиса ui и добавил фильтры для парсинга неструктурированных логов  
Добавил Grok-шаблоны  
Добавил Zipkin в проект и посмотрел его работу  
