# oglach

A distribution of fledge on Fedora Linux.

This is a test project to demo the capabilities of bootc using a complex project.

## run 

```
podman machine init --rootful --now
podman-bootc run --filesystem xfs ghcr.io/ubiquitous-factory/oglach:latest
```

## build 

If you want to modify the image before testing edit the `Containerfile` and run:

```
podman build -t <YOUR_REPO>/fledge .
podman push <YOUR_REPO>/fledge
```
