# --no-cache=true if you need to force things

docker-geo:
	docker build -f Dockerfile.geo -t whosonfirst-exportify-geo .

docker:
	docker build -f Dockerfile -t whosonfirst-exportify .
