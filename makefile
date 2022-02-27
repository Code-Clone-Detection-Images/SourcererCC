.PHONY: build save

NAME:=alpine-sourcerercc

build:
	@echo "Note, this is dummy mode operation and may use wrong envs"
	export SOURCERER_CC_INPUT="/home/sourcerercc-user/data/" && export LINK_FROM=$(pwd) && docker-compose build

# https://docs.docker.com/engine/reference/commandline/save/
save: build
	@echo "saving (this may take some time) [does not store the mysql, but only the main image]"
	docker save "sourcerercc_$(NAME):latest" | gzip > "$(NAME).tar.gz"
	@echo "saved to: \"$(NAME).tar.gz\""
# the other service is mysql