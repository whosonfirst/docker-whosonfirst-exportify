# docker-whosonfirst-exportify

"Exportify as a service"

## Important

This is work in progress.

```
docker build -f Dockerfile.ubuntu -t whosonfirst-exportify .
```

There is also a `Dockerfile.alpine` Dockerfile but it does not build as of this writing. Any help would be appreciated.

## Usage

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

## See also

* https://github.com/whosonfirst/py-mapzen-whosonfirst-export
