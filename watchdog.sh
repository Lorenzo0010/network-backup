#!/bin/sh
# Parametri di configurazione
TARGET_PRIMARY="1.1.1.1" # DNS Cloudflare
TARGET_SECONDARY="8.8.8.8" # DNS Google
MAX_FAILS=3
SLEEP_INTERVAL=30
FAILS=0
echo "=== Watchdog di rete avviato ==="
echo "Monitoraggio primario su: $TARGET_PRIMARY"
echo "Monitoraggio secondario su: $TARGET_SECONDARY"
echo "Intervallo di controllo: ${SLEEP_INTERVAL}s"
echo "Tentativi massimi prima del ripristino: $MAX_FAILS"
echo "================================="
while true; do
# Verifica il target primario, se fallisce prova il secondario
if ping -c 1 -W 3 "$TARGET_PRIMARY" > /dev/null 2>&1 || ping -c 1 -W 3 "$TARGET_SECONDARY" > /dev/null 2>&1; then
if [ "$FAILS" -gt 0 ]; then
echo "Connessione ripristinata o stabile."
fi
FAILS=0
else
FAILS=$((FAILS + 1))
echo "Avviso: Controllo connettività fallito ($FAILS/$MAX_FAILS) il $(date)"
fi
# Se i fallimenti superano la soglia, esegue l'azione di ripristino sull'host
if [ "$FAILS" -ge "$MAX_FAILS" ]; then
echo "CRITICAL: Connessione internet assente. Invocazione nsenter per ripristino rete su host..."
# Tenta il riavvio dei sottosistemi di rete standard di Ubuntu
# nsenter evade dal container ed esegue i comandi nel namespace del PID 1 (Host)
if nsenter -t 1 -m -u -n -i systemctl restart systemd-networkd > /dev/null 2>&1; then
echo "Comando 'systemd-networkd' inviato con successo."
elif nsenter -t 1 -m -u -n -i netplan apply > /dev/null 2>&1; then
echo "Comando 'netplan apply' inviato con successo."
elif nsenter -t 1 -m -u -n -i systemctl restart NetworkManager > /dev/null 2>&1; then
echo "Comando 'NetworkManager' inviato con successo."
else
echo "ERRORE: Impossibile trovare un gestore di rete compatibile tramite nsenter."
fi
echo "Attesa di 90 secondi per consentire la rinegoziazione DHCP prima del prossimo ciclo..."
sleep 90
FAILS=0
fi
sleep $SLEEP_INTERVAL
done
