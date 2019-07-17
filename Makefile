# --no-cache=true if you need to force things

docker:
	@make docker-ubuntu

docker-ubuntu:
	docker build -f Dockerfile.ubuntu -t whosonfirst-exportify .

docker-geo:
	docker build -f Dockerfile.geo -t whosonfirst-exportify-geo .
