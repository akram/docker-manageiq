#!/bin/bash
echo "Starting progress daemon"
# Start postgres daemon
exec su postgres -c "/usr/pgsql-9.4/bin/postgres -D /var/lib/pgsql/9.4/data" &
echo "Starting progress daemon: Done"

echo "Updating postgres default password"
# Update default postgres user password
exec su postgres -c "psql -c \"alter user postgres password 'password'\";" &
echo "Updating postgres default password: Done"



