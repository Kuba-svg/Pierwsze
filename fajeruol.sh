#!bin/bash
iptables -F
iptables -X
ipset restore -f ipset-zabbix.bqp
ipset restore -f ipset-blacklist.bqp
iptables-restore < /etc/iptables/rules.v4.bqp
iptables -S
echo "gotowe"
