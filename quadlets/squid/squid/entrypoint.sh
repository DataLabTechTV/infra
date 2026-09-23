#!/bin/sh

SQUID_USER="squid"
CACHE_DIR="/var/cache/squid"
SSL_DB="$CACHE_DIR/ssl_db"

tail -F /var/log/squid/access.log 2>/dev/null &
tail -F /var/log/squid/cache.log 2>/dev/null &

if [ ! -d "$CACHE_DIR/00" ]; then
    echo "Initializing cache..."
    /usr/sbin/squid -Nz
    echo "Done"
fi

if [ ! -f "$SSL_DB/index.txt" ]; then
    sudo -u "$SQUID_USER" /usr/lib/squid/security_file_certgen \
        -c \
        -s "$SSL_DB" \
        -M 4MB
fi

exec /usr/sbin/squid -N -f /etc/squid/squid.conf "$@"
