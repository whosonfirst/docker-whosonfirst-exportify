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