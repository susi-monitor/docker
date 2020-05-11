# docker

susi-monitor docker image

How to run it?

On local machine this will suffice

`docker run -it -p 80:80 -e BASEURL=http://localhost`

Basically bind port 80 to something and provide BASEURL (in `http(s)://HOSTNAME` format) - that's it.

By default SuSi-monitor uses SQLite DB stored in `/data/` so you may wish to mount
it for persistence.

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
- `VERIFYHOST` - enable this if you need to verify certificates when polling (default: disabled)
- `VERIFYPEER` - same as above
