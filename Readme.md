# Supervisor (in Docker)

Prepared image of php-cli in newest stable version and supervisord for handling
stable run of processes such as horizon or websockets server or just give access
to artisan. This image also handling Artisan Task Manager (via cron).

## Arguments

* **user_uid** - nginx user UID value (default: *1001*)
* **group_gid** - nginx group GID value (default: *1001*)

## PHP Modules

* opcache
* PDO (Mysql)
* Mbstring
* exif
* curl
* bcmath
* pcntl
* redis
* gd
* gmp
* imagick
* intl
* zip

## Paths

* Main application path is **/var/www**
* Supervisor config dir is **/etc/supervisor/conf.d**
* Supervisor log is stored in **/var/log/supervisor.log**
* Cron log is in **/var/logcron.log**