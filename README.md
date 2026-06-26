# Network Watchdog Container

Container leggero progettato per monitorare lo stato della connettività internet su un server Ubuntu ospite e riavviare i servizi di rete nativi in caso di disconnessione prolungata.

## Requisiti di Esecuzione

Per consentire al container di agire sulle interfacce fisiche dell'host e verificare la reale tabella di instradamento, è necessario eseguirlo con i seguenti privilegi:
- `--privileged` (permette l'uso di `nsenter`)
- `--net=host` (condivide lo stack di rete dell'host)
- `--pid=host` (permette l'accesso al PID 1 dell'host per evadere il namespace)

## Avvio tramite Docker Compose

```yaml
version: '3.8'
services:
  network-watchdog:
    image: YOUR_DOCKERHUB_USERNAME/network-watchdog:latest
    container_name: network-watchdog
    privileged: true
    network_mode: "host"
    pid: "host"
    restart: unless-stopped
```
