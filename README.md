# Vpl Jail - Docker

This repo contains the Dockerfile to build the image for Vpl Jail Execution

[Visit the original project](https://vpl.dis.ulpgc.es/)

# Build

# Arguments

1. VERSION: Jail version that you want to add to the container


# RUN

**You need to run the container with privilegies and ALL capabilities**

`docker run -p 8888:8888 -e JAIL_PORT=8888  -e JAIL_SECURE_PORT=4433 --cap-add=ALL --privileged=true  alphonse92/vpl-jail-execution-java`

# Environment variables

1. JAIL_PORT: Jail port
2. JAIL_SECURE_PORT: jail secure port



