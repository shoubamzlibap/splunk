#!/bin/bash
trap 'kill $(jobs -p)' SIGINT
# generate logs for three hosts
for i in 1 2 3; do
	# weblogs
	./gogen -c mygogens/myweblog.yml -o file -f /opt/log/www${i}/access.log gen -r -c 1 -i 10 &
	# secure logs
	./gogen -c mygogens/securelog${i}.yml -o file -f /opt/log/www${i}/secure.log &
done

wait
