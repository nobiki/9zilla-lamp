Dockerfile: Dockerfile.in ./include/*.docker
	cpp -P -o Dockerfile Dockerfile.in

update:
	git pull origin master
	git submodule update --init --recursive
	git submodule foreach git pull origin master
	cp ./9zilla/Dockerfile.in.lamp ./Dockerfile.in

build: Dockerfile
	docker build --no-cache -t 9zilla-lamp:latest .
