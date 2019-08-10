# --no-cache=true if you need to force things

docker:
	docker build -t whosonfirst-exportify .

flask-server:
	docker run -it -p 7777:7777 whosonfirst-exportify /usr/local/bin/wof-exportify-www --host 0.0.0.0

gunicorn-server:
	docker run -it -p 7777:7777 whosonfirst-exportify gunicorn --chdir /usr/local/bin --bind 0.0.0.0:7777 --worker-class=gevent --workers 4 wof-exportify-www:app
