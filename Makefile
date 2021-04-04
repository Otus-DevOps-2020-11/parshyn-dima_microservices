include ${PWD}/docker/.env
DOCKER_IMAGES = $(shell docker images -q)
DOCKER_CONTAINERS=$(shell docker ps -a -q)

# Выводит описание целей - все, что написано после двойного диеза (##) через пробел
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | sed -e 's/\(\:.*\#\#\)/\:\ /' | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

#===================================================== DOCKER BUILD =====================================================================


build-all: build-prometheus build-ui build-comment build-post build-mongodb-exporter build-blackbox-exporter build-alertmanager build-telegraf build-fluentd ## Создать все docker образы проекта

build-prometheus: ## Создание docker-образа для контейнера prometheus
	cd monitoring/prometheus && \
	docker image build -t $(USER_NAME)/prometheus:$(PROMETHEUS_TAG) .
build-ui: ## Создание docker-образа для контейнера ui
	cd src/ui && \
	USER_NAME=$(USER_NAME) bash docker_build.sh
build-comment: ## Создание docker-образа для контейнера comment
	cd src/comment && \
	USER_NAME=$(USER_NAME) bash docker_build.sh
build-post: ## Создание docker-образа для контейнера post
	cd src/post-py && \
	USER_NAME=$(USER_NAME) bash docker_build.sh
build-mongodb-exporter: ## Создание docker-образа для контейнера mongodb-exporter
	cd monitoring/mongodb_exporter && \
	docker image build -t $(USER_NAME)/mongodb-exporter:$(MONGOEXP_TAG) .
build-blackbox-exporter: ## Создание docker-образа для контейнера blackbox-exporter
	cd monitoring/blackbox_exporter && \
	docker image build -t $(USER_NAME)/blackbox-exporter:$(BLKBOXEXP_TAG) .
build-alertmanager: ## Создание docker-образа для контейнера alertmanager
	cd monitoring/alertmanager && \
	docker image build -t $(USER_NAME)/alertmanager:$(ALERTMANAGER_TAG) .
build-telegraf: ## Создание docker-образа для контейнера telegraf
	cd monitoring/telegraf && \
	docker image build -t $(USER_NAME)/telegraf:$(TELEGRAF_TAG) .
build-fluentd: ## Создание docker-образа для контейнера telegraf
	cd logging/fluentd && \
	docker image build -t $(USER_NAME)/fluentd .

#===================================================== DELETE =====================================================================

delete-container-all: ## Остановить и удалить все запущенные контейнеры
	docker stop $(DOCKER_CONTAINERS) && \
	docker rm $(DOCKER_CONTAINERS)

delete-image-all: ## Удалить все docker образы
	docker image rm -f $(DOCKER_IMAGES)

#===================================================== REGESTRY =====================================================================

docker-login:
	docker login -u $(USER_NAME)

push-all: push-prometheus push-ui push-comment push-post push-mongodb-exporter push-blackbox-exporter push-alertmanager push-telegraf push-fluentd

push-prometheus: ## Сохранение docker-образа prometheus в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/prometheus:$(PROMETHEUS_TAG)
push-ui: ## Сохранение docker-образа ui в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/ui:$(UI_TAG)
push-comment: ## Сохранение docker-образа comment в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/comment:$(COMMENT_TAG)
push-post: ## Сохранение docker-образа post в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/post:$(POST_TAG)
push-mongodb-exporter: ## Сохранение docker-образа mongodb-exporter в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/mongodb-exporter:$(MONGOEXP_TAG)
push-blackbox-exporter: ## Сохранение docker-образа blackbox-exporter в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/blackbox-exporter:$(BLKBOXEXP_TAG)
push-alertmanager: ## Сохранение docker-образа alertmanager в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/alertmanager:$(ALERTMANAGER_TAG)
push-telegraf: ## Сохранение docker-образа telegraf в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/telegraf:$(TELEGRAF_TAG)
push-fluentd: ## Сохранение docker-образа fluentd в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/fluentd:$(FLUENTD_TAG)

#===================================================== DOCKER-COMPOSE =====================================================================

docker-compose-up: ## Запуск application контейнеров с помощью docker-compose (docker-compose.yml)
	cd docker && \
	docker-compose -f docker-compose.yml up -d

docker-compose-down: ## Остановка application контейнеров с помощью docker-compose (docker-compose.yml)
	cd docker && \
	docker-compose -f docker-compose.yml down

docker-compose-up-monitoring: ## Запуск monitoring контейнеров с помощью docker-compose (docker-compose-monitoring.yml)
	cd docker && \
	docker-compose -p monitoring -f docker-compose-monitoring.yml up -d

docker-compose-down-monitoring: ## Остановка monitoring контейнеров с помощью docker-compose (docker-compose-monitoring.yml)
	cd docker && \
	docker-compose -p monitoring -f docker-compose-monitoring.yml down

docker-compose-up-logging: ## Запуск logging контейнеров с помощью docker-compose (docker-compose-logging.yml)
	cd docker && \
	docker-compose -f docker-compose-logging.yml up -d

docker-compose-down-logging: ## Остановка logging контейнеров с помощью docker-compose (docker-compose-logging.yml)
	cd docker && \
	docker-compose -f docker-compose-logging.yml down
