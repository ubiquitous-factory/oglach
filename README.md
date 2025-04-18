# oglach

A distribution of fledge on Fedora Linux using bootc.

This project aims to demonstrate a production level bootc deployment system using [CLOS](https://clos.mehal.tech).   

## run as container 
```
podman run --rm --name fledge -d -p 8081:8081 -p 1995:1995 -p 8080:80 ghcr.io/ubiquitous-factory/oglach:latest
podman exec -ti fledge bash
```

Browse to http://localhost:8080
login: admin 
password: fledge

## run as bootc image

Unfortunately podman-bootc doesn't support [arbitrary port parameters](https://github.com/containers/podman-bootc/issues/6) yet.
```
podman machine init --rootful --now
podman-bootc run --filesystem xfs ghcr.io/ubiquitous-factory/oglach:latest
```

## validate 

Ensure service is running

```bash
systemctl status fledge

● fledge.service - Run fledge
     Loaded: loaded (/etc/systemd/system/fledge.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf, 50-keep-warm.conf
     Active: active (running) since Tue 2025-04-15 22:17:49 UTC; 9min ago
 Invocation: 8b16826bb88940388c296752b5308cac
    Process: 1002 ExecStart=/usr/local/fledge/bin/fledge start (code=exited, status=0/SUCCESS)
      Tasks: 23 (limit: 2181)
     Memory: 92.6M (peak: 199.4M)
        CPU: 10.417s
     CGroup: /system.slice/fledge.service
             ├─1229 python3 -m fledge.services.core
             └─1322 /usr/local/fledge/services/fledge.services.storage --address=0.0.0.0 --port=35057

Apr 15 22:17:46 fedora python3[1229]: Fledge[1229] INFO: server: fledge.services.core.server: PID [1229] written in [/etc/fledge/data/var/run/fledge.core.pid]
Apr 15 22:17:46 fedora python3[1229]: Fledge[1229] INFO: server: fledge.services.core.server: REST API Server started on http://0.0.0.0:8081
Apr 15 22:17:47 fedora python3[1229]: Fledge[1229] INFO: service_registry: fledge.services.core.service_registry.service_registry: Registered service instance id=5b65b957-8384-4fe3-aae5-692>
Apr 15 22:17:48 fedora logger[1421]: Fledge [1412] INFO: scripts.services.storage: Fledge storage microservice found in FLEDGE_ROOT location: /usr/local/fledge
Apr 15 22:17:48 fedora logger[1419]: Fledge [1415] INFO: scripts.services.storage: Fledge storage microservice found in FLEDGE_ROOT location: /usr/local/fledge
Apr 15 22:17:48 fedora logger[1467]: Fledge [1397] ERROR: fledge.check_certs: Certificate /etc/fledge/data/etc/certs/*.cert will expire in less than a day
Apr 15 22:17:49 fedora fledge[1002]: Starting Fledge v3.0.0.........
Apr 15 22:17:49 fedora logger[1523]: Fledge [1002] INFO: script.fledge: Fledge started.
Apr 15 22:17:49 fedora fledge[1002]: Fledge started.
Apr 15 22:17:49 fedora systemd[1]: Started fledge.service - Run fledge.

```

Ping the service

```bash
curl -s http://localhost:8081/fledge/ping ; echo
{"uptime": 10480, "dataRead": 0, "dataSent": 0, "dataPurged": 0, "authenticationOptional": true, "serviceName": "Fledge", "hostName": "fledge", "ipAddresses": ["x.x.x.x", "x:x:x:x:x:x:x:x"], "health": "green", "safeMode": false}
```

Login 
```bash
curl -X POST http://localhost:8081/fledge/login -d'
{
  "username" : "admin",
  "password" : "fledge"
}'

{"message": "Logged in successfully.", "uid": 1, "token": "<TOKEN>", "admin": true}
```

Get the statistics with token

```bash
curl -H "authorization: <TOKEN>" -s http://localhost:8081/fledge/statistics ; echo
[{"key": "BUFFERED", "description": "Readings currently in the Fledge buffer", "value": 0}, {"key": "DISCARDED", "description": "Readings discarded by the South Service before being  placed in the buffer. This may be due to an error in the readings themselves.", "value": 0}, {"key": "PURGED", "description": "Readings removed from the buffer by the purge process", "value": 0}, {"key": "READINGS", "description": "Readings received by Fledge", "value": 0}, {"key": "UNSENT", "description": "Readings filtered out in the send process", "value": 0}, {"key": "UNSNPURGED", "description": "Readings that were purged from the buffer before being sent", "value": 0}]
```



## build 

If you want to modify the image before testing edit the `Containerfile` and run:

```
podman build -t <YOUR_REPO>/fledge .
podman push <YOUR_REPO>/fledge
```
