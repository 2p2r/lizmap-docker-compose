.PHONY: env

LIZMAP_VERSION_TAG:=3.4
POSTGIS_VERSION_TAG:=11-2.5
QGIS_VERSION_TAG:=3.16

QGIS_MAP_WORKERS:=1
WPS_NUM_WORKERS:=1

LIZMAP_PORT:=127.0.0.1:8090
OWS_PORT:=127.0.0.1:8091
WPS_PORT:=127.0.0.1:8092
LIZMAP_POSTGRESQL_PORT:=5432

LIZMAP_DIR=$(shell pwd)/lizmap
LIZMAP_USER_ID:=$(shell id -u)
LIZMAP_USER_GID:=$(shell id -g)

env:
	@mkdir -p $(LIZMAP_DIR)/www/var/log \
			  $(LIZMAP_DIR)/var/log/nginx \
			  $(LIZMAP_DIR)/var/nginx-cache \
			  $(LIZMAP_DIR)/var/lizmap-theme-config \
			  $(LIZMAP_DIR)/var/lizmap-db \
			  $(LIZMAP_DIR)/var/lizmap-config \
			  $*
	@@{\
		echo "Creating environment file for docker-compose";\
		echo "LIZMAP_DIR=$(LIZMAP_DIR)" > .env;\
		echo "LIZMAP_USER_ID=$(LIZMAP_USER_ID)" >> .env;\
		echo "LIZMAP_USER_GID=$(LIZMAP_USER_GID)" >> .env;\
		echo "LIZMAP_VERSION_TAG=$(LIZMAP_VERSION_TAG)" >> .env;\
		echo "QGIS_VERSION_TAG=$(QGIS_VERSION_TAG)" >> .env;\
		echo "POSTGIS_VERSION_TAG=$(POSTGIS_VERSION_TAG)" >> .env;\
		echo "QGIS_MAP_WORKERS=$(QGIS_MAP_WORKERS)" >> .env;\
		echo "WPS_NUM_WORKERS=$(WPS_NUM_WORKERS)" >> .env;\
		echo "LIZMAP_PORT=$(LIZMAP_PORT)" >> .env;\
		echo "LIZMAP_POSTGRESQL_PORT=$(LIZMAP_POSTGRESQL_PORT)" >> .env;\
		echo "OWS_PORT=$(OWS_PORT)" >> .env;\
		echo "WPS_PORT=$(WPS_PORT)" >> .env;\
	}

#
# Generate a docker-compose .env file at each
# `run` invocation. 
# This enable using the `docker-compose` commands without
# relying on the Makefile
#
run: env
	@echo "NOTE: To restart a service, consider:"
	@echo "  > docker-compose restart <service>"
	docker-compose rm -f || true
	docker-compose up

start: run

# Force stopping and removing containers
rm:
	docker-compose stop || true
	docker-compose rm -f

stop: rm

clean: stop
	rm -rf $(LIZMAP_DIR)/www/*
	rm -rf $(LIZMAP_DIR)/var/*
	rm -rf $(LIZMAP_DIR)/wps-data/*

# Pull images from github 3liz
pull:
	docker pull 3liz/lizmap-web-client:${LIZMAP_VERSION_TAG}
	docker pull 3liz/qgis-map-server:${QGIS_VERSION_TAG}
	docker pull 3liz/qgis-wps:${QGIS_VERSION_TAG}
	docker pull 3liz/postgis:${POSTGIS_VERSION_TAG}


