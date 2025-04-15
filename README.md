# oglach

A distribution of fledge on Fedora Linux.

This is a test project to demo the capabilities of bootc using a complex project.

## run 

```
podman machine init --rootful --now
podman-bootc run --filesystem xfs ghcr.io/ubiquitous-factory/oglach:latest
```

## validate 

Ensure service is running

```
systemctl status fledge
```

Ping the service

```
curl -s http://localhost:8081/fledge/ping ; echo
{"uptime": 10480, "dataRead": 0, "dataSent": 0, "dataPurged": 0, "authenticationOptional": true, "serviceName": "Fledge", "hostName": "fledge", "ipAddresses": ["x.x.x.x", "x:x:x:x:x:x:x:x"], "health": "green", "safeMode": false}
```

Get the statistics
```
curl -s http://localhost:8081/fledge/statistics ; echo
[{"key": "BUFFERED", "description": "Readings currently in the Fledge buffer", "value": 0}, {"key": "DISCARDED", "description": "Readings discarded by the South Service before being  placed in the buffer. This may be due to an error in the readings themselves.", "value": 0}, {"key": "PURGED", "description": "Readings removed from the buffer by the purge process", "value": 0}, {"key": "READINGS", "description": "Readings received by Fledge", "value": 0}, {"key": "UNSENT", "description": "Readings filtered out in the send process", "value": 0}, {"key": "UNSNPURGED", "description": "Readings that were purged from the buffer before being sent", "value": 0}]
```

## build 

If you want to modify the image before testing edit the `Containerfile` and run:

```
podman build -t <YOUR_REPO>/fledge .
podman push <YOUR_REPO>/fledge
```
