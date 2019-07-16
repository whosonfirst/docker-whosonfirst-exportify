# docker-whosonfirst-exportify

"Exportify as a service"

## Important

This is not ready for you to use yet.

## To do

* A simple Flask app that accepts WOF records as `POST` requests and emits "exportified" WOF records. This should eventually be moved in to a discrete package (read: probably not `py-mapzen-whosonfirst-export` because of the Flask dependencies).

* Hooks to handle abuse (max upload size, basic is-this-even-a-WOF-record checking, etc.).

* Support for "alt" files (this can probably wait until v1.x).

* Updating the `Dockerfile` to expose the Flask app on port `xxxx`.

* Figure out the how and what of getting Alpine to install geo dependencies from `apk`. Currently we are building `libgeos`, `libgdal` and `libproj` from source so that takes... a while.

## Usage

First build an image with all the geo stuff compiled from source. We do this as a separate step because it takes so damn long (see above). Ultimately the goal is to make `Dockerfile.geo` go away.

```
docker build -f Dockerfile.geo -t whosonfirst-exportify-geo .
```

Now build the Who's On First "exportify" stuff. Note that we are assuming the presence of a `whosonfirst-exportify-geo` image (see above) rather than `alpine:latest`.

```
docker build -f Dockerfile -t whosonfirst-exportify .
```

And then:

```
docker run whosonfirst-exportify /usr/bin/wof-exportify -h
Usage: wof-exportify [options]

Options:
  -h, --help            show this help message and exit
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
