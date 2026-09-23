#!/bin/sh

SSL_DB=/var/cache/squid/ssl_db

tail -F /var/log/squid/access.log 2>/dev/null &
tail -F /var/log/squid/cache.log 2>/dev/null &

if [ ! -f "$SSL_DB/index.txt" ]; then
    /usr/lib/squid/security_file_certgen \
        -c \
        -s "$SSL_DB" \
        -M 4MB
fi

/usr/sbin/squid -Nz

exec /usr/sbin/squid -N -f /etc/squid/squid.conf "$@"
