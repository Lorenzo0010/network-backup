FROM alpine:3.19
# Installazione delle utility di rete avanzate e di nsenter (contenuto in util-linux)
RUN apk add --no-cache iputils util-linux tzdata
# Configurazione dello script di esecuzione
COPY watchdog.sh /usr/local/bin/watchdog.sh
RUN chmod +x /usr/local/bin/watchdog.sh
# Avvio del processo di monitoraggio
ENTRYPOINT ["/usr/local/bin/watchdog.sh"]
