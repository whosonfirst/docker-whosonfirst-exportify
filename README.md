# docker-whosonfirst-exportify

"Exportify" Who's On First documents, as a service.

## Description

This container image exports tools and services for "exportifying" Who's On
First (WOF) GeoJSON documents, making them ready to be included in a
commit or pull request in a [https://github.com/whosonfirst-data](whosonfirst-data) repository.

When a WOF record is "exportified" a number of derived properties are
automatically updated (for example `wof:belongsto`, `src:geom_hash` and
`wof:lastmodified`) and the document is formatted according to the WOF style
guide (specifically that GeoJSON properties but _not_ geometries be indented).

All of this logic is handled by the
[py-mapzen-whosonfirst-export](https://github.com/whosonfirst/py-mapzen-whosonfirst-export)
library and is made available through the `wof-exportify` command line tool and
the `wof-exportify-www` server (which is part of the
[whosonfirst-www-exportify](https://github.com/whosonfirst/whosonfirst-www-exportify) package.

## Setup

```
$> docker build -f Dockerfile.ubuntu -t whosonfirst-exportify .
```

I tried to get all this working under `alpine` but there appears to be a number of problems installing GDAL related tools. Any help would be appreciated.

## Usage

### wof-exportify

```
$> docker run whosonfirst-exportify /usr/local/bin/wof-exportify -h
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
$> cat 101736545.geojson | docker run -i whosonfirst-exportify /usr/local/bin/wof-exportify -e stdout --stdin | jq '.properties["wof:name"]'
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

#### wof-exportify-www (with gunicorn)

```
$> docker run -it -p 7777:7777 whosonfirst-exportify gunicorn --chdir /usr/local/bin --bind 0.0.0.0:7777 --worker-class=gevent --workers 4 wof-exportify-www:app
[2019-07-17 16:20:46 +0000] [1] [INFO] Starting gunicorn 19.7.1
[2019-07-17 16:20:46 +0000] [1] [INFO] Listening at: http://0.0.0.0:7777 (1)
[2019-07-17 16:20:46 +0000] [1] [INFO] Using worker: gevent
[2019-07-17 16:20:46 +0000] [10] [INFO] Booting worker with pid: 10
[2019-07-17 16:20:46 +0000] [12] [INFO] Booting worker with pid: 12
[2019-07-17 16:20:47 +0000] [14] [INFO] Booting worker with pid: 14
[2019-07-17 16:20:47 +0000] [16] [INFO] Booting worker with pid: 16
```

For example:

```
$> curl -s -X POST -H "Content-Type: application/json" -d @101736545.geojson 127.0.0.1:7777 | jq '.properties["wof:name"]'
"Montreal"
```

## ECS

Running `docker-whosonfirst-exportify` using the AWS Elastic Container Service (ECS)

### Security Group(s)

Let's imagine that you're going to set up a ELB (specifically an application
load balancer) to listen on port `443` and relay traffic to the ECS container on
port `8080`.

The details of setting up TLS certificates for the ELB are outside the scope of this discussion.

#### whosonfirst-exportify-elb

Allow in-bound traffic on port `443`.

#### whosonfirst-exportify-ecs

Allow in-bound traffic on port `8080`.

### Elastic Load Balancer

Create a new application load balancer called `whosonfirst-exportify-elb.

Assign the `whosonfirst-exportify-elb` security group to it.

#### Target Groups

This is the part I totally don't understand. In order to create the ELB you
have to create a target group. But then later, when you're setting up the (ECS)
service it will create some sort of "magic" target group that will add/remove
your (ECS) tasks as they are spun up or down.

So, just create any old target group and assume you'll delete it later...

If you could create a target group you'd do something like this:

| Property | Value |
| --- | --- | 
| Target group name | `whosonfirst-exportify-target` |
| Target type | IP |
| Protocol | HTTP | 
| Port | 8080 | 
| VPC | ... |

For the health check:

| Property | Value |
| --- | --- | 
| Protocol | HTTP | 
| Path | `/ping` | 


### Repository (containers)

Generally I try to make sure containers get tagged with the same release number as [whosonfirst-www-exportify](https://github.com/whosonfirst/whosonfirst-www-exportify)

### Task definition

#### Task definition name

Something like `whosonfirst-exportify`.

#### Requires compatibilities

Make sure to check `FARGATE`.

#### Task role

Just use the default `ecsTaskExecutionRole`.

#### Container Definitions 

Choose the relevant container and under `Environment, Command` add:

```
gunicorn,--chdir,/usr/local/bin,--bind,0.0.0.0:8080,--worker-class=gevent,--workers,4,wof-exportify-www:app_with_max_content_length(1048576)
```

Adjust the value in `wof-exportify-www:app_with_max_content_length(...)` to taste.

### Cluster

Use an exsiting ECS cluster or create a new one called `whosonfirst-exportify`

### Service

The step continues to baffle me.

| Property | Value |
| --- | --- |
| Launch type | `FARGATE` |
| Task Definition (family) | `whosonfirst-exportify` | 
| Revision | `xx (latest)` | 
| Service name |  `whosonfirst-exportify` | 
| Number of tasks | 1 |

#### Networking

Configure your VPC and subnets as desired.

| Property | Value |
| --- | --- | 
| Security groups | `whosonfirst-exportify-ecs` |
| Auto-assign public IP | ENABLED | 

#### Load balancing

| Property | Value |
| --- | --- |
| Load balancer type | Application load balancer |
| Load balancer name | `whosonfirst-exportify-elb` |

Under "Container to load balance" choose `whosonfirst-exportify:8080:8080`
(there shouldn't be any other, then "Add container".

Now we get to the "Container to load balance" part of things.

| Property | Value |
| --- | --- |
| Production listener port* | `443:HTTPS` |
| Target group name | (see notes below) |
| Target group protocol | HTTP | 
| Target type | ip | 
| Path pattern | `/` |
| Evaluation order | 1 | 
| Health check path  | `/ping` |

Notes about `Target group name`:

So far as I can tell you'll have one or two options here:

1. Create a new target group
2. If you've already created this service and by extension its target group
   before then it (the target group) will be an option to choose. If you just
   create a target group with similar settings in the EC2 console it _won't_ be
   present. I have no idea why...

#### Service discovery 

Disable the `Enable service discovery integration` checkbox.

## See also

* https://github.com/whosonfirst/py-mapzen-whosonfirst-export
* https://github.com/whosonfirst/whosonfirst-www-exportify
* https://spelunker.whosonfirst.org/id/101736545/
