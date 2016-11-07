Dockerfile: Dockerfile.in ./9zilla/include/*.docker
	cpp -P -o Dockerfile Dockerfile.in

build: Dockerfile
	docker build --no-cache -t 9zilla-lamp:latest .
