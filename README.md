# docker

[**susi-monitor**](https://susi-monitor.github.io/) docker image

How to run it?

On local machine this will suffice:

`docker run -it -p 80:80 -e CRON_ENABLED=true BASEURL=http://localhost`

Basically bind port 80 to something and provide BASEURL (in `http(s)://HOSTNAME` format) - that's it.

By default SuSi-monitor uses SQLite DB stored in `/data/` so you may want to mount
it for persistence.

---
Optionally you may wish to customize rest of variables:
- `ADMIN_PASSWORD` - password for /admin page
- `PAGE_TITLE` - custom page title
- `NOTIFICATIONS_ENABLED` - if you wish to enable notifications to IMs (true or false)
- `TEAMS_WEBHOOK_URL` - full URL of Teams webhook
- `UA_STRING` - custom User Agent used when polling targets
- `PROXY_ENABLED` - if you need proxy (true or false)
- `PROXY_HOST` - proxy host, can be IP, protocol not needed
- `PROXY_PORT` - proxy port
- `PROXY_CREDENTIALS` - user:password format
- `PROXY_ENABLED_NOTIFICATIONS` - this and below proxy settings are to be used when sending notifications
- `PROXY_HOST_NOTIFICATIONS` - see above
- `PROXY_PORT_NOTIFICATIONS` - see above
- `PROXY_CREDENTIALS_NOTIFICATIONS` - see above
- `VERIFYHOST` - enable this if you need to verify certificates when polling (default: disabled)
- `VERIFYPEER` - same as above
- `SHELL_EXEC_CURL` - exec cURL binary rather than libcurl call

Database variables :
(if you do not provide them then SQLITE is used by default)

- `DB_DSN` - full connection string (OR provide host, driver, and DB name etc. separately)
- `DB_HOSTNAME` ,
- `DB_NAME`,
- `DB_USERNAME`,
- `DB_PASSWORD`,
- `DB_DRIVER` - currently supported drivers are `mysqli`, `oci8`, `pdo`, `postgre`, `sqlite3`. 
                                        For options other than default (sqlite3) or mysqli (where there is sample 
                                        DB structure SQL provided) you will have to create the database structure yourself. 
                                        If you want to set external DB then using MYSQL is recommended.
- `DB_PREFIX`