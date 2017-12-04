#!/bin/bash

wsprocess="httpd"

nr=1
for i in $(ps -ylC $wsprocess --sort:rss | awk '{print $9}' | grep -v "SZ"); do                                                                                                                                                               #for HM
        temp_total=`expr $temp_total + $i`
        nr=`expr $nr + 1`
done
avgkb=$(expr $temp_total / $nr)
avg=$(expr $avgkb / 1024)
echo "Found an average memory usage of apache as follows: $avg mb"
reserved=$(ps aux | grep -v "$wsprocess" | awk '{sum+=$6} END {print sum / 1024}                                                                                                                                                              ') #for HM
totalmemkb=$(cat /proc/meminfo | grep "MemTotal" | awk '{print $2}')
totalmem=$(expr $totalmemkb / 1024)
left=$(echo "$totalmem - $reserved" | bc)
if [ $totalmem -lt 1024 ]; then
        maxrequestsperchild="666"
fi
if [ $totalmem -gt 1024 ]; then
        maxrequestsperchild="1024"
fi
if [ $totalmem -gt 2048 ]; then
        maxrequestsperchild="2048"
fi
if [ $totalmem -gt 3068 ]; then
        maxrequestsperchild="3068"
fi
if [ $totalmem -gt 4096 ]; then
        maxrequestsperchild="4096"
fi

echo "Found total available memory $totalmem, reserved: $reserved, left: $left"
maxclients=$(echo "($totalmem - $reserved) / $avg" | bc)
serverlimit=$maxclients
tmp=$(echo "($maxclients / 100) * 30" | bc -l)
startservers=$(echo "($tmp+0.5)/1" | bc)
tmp=$(echo "($maxclients / 100) * 5" | bc -l)
minspareservers=$(echo "($tmp+0.5)/1" | bc)
tmp=$(echo "($maxclients / 100) * 10" | bc -l)
maxspareservers=$(echo "($tmp+0.5)/1" | bc)

echo -e "<IfModule prefork.c>"
echo -e "\tStartServers\t\t$startservers"
echo -e "\tMinSpareServers\t\t$minspareservers"
echo -e "\tMaxSpareServers\t\t$maxspareservers"
echo -e "\tServerLimit\t\t$serverlimit"
echo -e "\tMaxClients\t\t$maxclients"
echo -e "\tMaxRequestsPerChild\t$maxrequestsperchild"
echo -e "</IfModule>"
