#!/bin/sh

squid_user="squid"
cache_dir="/var/cache/squid"
ssl_dir="/etc/squid/ssl"
cert="$ssl_dir/squid-ca.crt"
key="$ssl_dir/squid-ca.key"
ssl_db="$cache_dir/ssl_db"

if [ ! -d "$cache_dir/00" ]; then
    echo "Initializing cache..."
    /usr/sbin/squid -Nz
    echo "Done"
fi

if [ -f "${cert}.new" ] && [ -f "${key}.new" ]; then
    echo "Updating Squid CA..."
    mv -v "${cert}.new" "$cert"
    mv -v "${key}.new" "$key"
    rm -rfv "$ssl_db"
fi

if [ ! -f "$ssl_db/index.txt" ]; then
    su -s /bin/sh "$squid_user" -c \
        "/usr/lib/squid/security_file_certgen -c -s '$ssl_db' -M 4MB"
fi

exec /usr/sbin/squid -N -f /etc/squid/squid.conf "$@"
