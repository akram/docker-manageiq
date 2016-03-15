nohup /start_postgres.sh &

echo "waiting for the DB to start"
sleep 5

ln -s /manageiq/config/database.pg.yml /manageiq/config/database.yml
cd /manageiq

if [ -e /var/lib/pgsql/initialized ]
then
	echo "Reusing existing DB"
else
	echo "Init DB"
	su postgres /createDB.sh
	rake db:migrate
	touch /var/lib/pgsql/initialized
fi

rake evm:start
tail -f /manageiq/log/evm.log


