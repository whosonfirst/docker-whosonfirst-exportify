# --no-cache=true if you need to force things

docker:
	@make docker-ubuntu

docker-alpine:
	docker build -f Dockerfile.alpine -t whosonfirst-exportify .

docker-ubuntu:
	docker build -f Dockerfile.ubuntu -t whosonfirst-exportify .

docker-geo:
	docker build -f Dockerfile.geo -t whosonfirst-exportify-geo .
