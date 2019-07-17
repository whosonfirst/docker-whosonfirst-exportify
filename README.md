# docker-whosonfirst-exportify

"Exportify as a service"

## Important

This is work in progress.

## Setup

```
docker build -f Dockerfile.ubuntu -t whosonfirst-exportify .
```

I tried to get all this working under `alpine` but there appears to be a number of problems installing GDAL related tools. Any help would be appreciated.

## Usage

### wof-exportify

```
docker run whosonfirst-exportify /usr/local/bin/wof-exportify -h
Usage: wof-exportify [options]

Options:
  -h, --help            show this help message and exit
  -e EXPORTER, --exporter=EXPORTER
  -s SOURCE, --source=SOURCE
  -i ID, --id=ID        
  -p PATH, --path=PATH  
  -c, --collection      
  -a ALT, --alt=ALT     
  -d DISPLAY, --display=DISPLAY
  --stdin               
  --debug               
  -v, --verbose         Be chatty (default is false)
```

For example:

```
cat 101736545.geojson | docker run -i whosonfirst-exportify /usr/local/bin/wof-exportify -e stdout --stdin | jq '.properties["wof:name"]'
"Montreal"
```

Note the `-i` flag which is important if you're trying to pipe documents in to the container.

### wof-exportify-www

```
$> docker run -it -p 7777:7777 whosonfirst-exportify /usr/local/bin/wof-exportify-www --host 0.0.0.0
 * Serving Flask app "wof-exportify-www" (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
INFO:werkzeug: * Running on http://0.0.0.0:7777/ (Press CTRL+C to quit)
INFO:werkzeug:172.17.0.1 - - [17/Jul/2019 16:00:53] "POST / HTTP/1.1" 200 -
```

For example:

```
$> curl -s -X POST -H "Content-Type: application/json" -d @101736545.geojson 127.0.0.1:7777 | jq '.properties["wof:name"]'
"Montreal"
```

The details surrounding the use of `wof-exportify-www` may change in order to run it under `gunicorn` but that remains to be determined.

## See also

* https://github.com/whosonfirst/py-mapzen-whosonfirst-export
* https://github.com/whosonfirst/whosonfirst-www-exportify
