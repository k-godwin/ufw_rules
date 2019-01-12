#!/bin/sh

DIR="$(dirname $(readlink -f $0))"
cd $DIR
/usr/bin/wget https://www.cloudflare.com/ips-v4 -qO /tmp/ips-v4.tmp
/usr/bin/wget https://www.cloudflare.com/ips-v6 -qO /tmp/ips-v6.tmp
mv /tmp/ips-v4.tmp /tmp/ips-v4
mv /tmp/ips-v6.tmp /tmp/ips-v6

# Warning: This resets UFW and rebuilds it.
/usr/sbin/ufw --force reset
/usr/sbin/ufw default deny incoming
/usr/sbin/ufw default deny outgoing
/usr/sbin/ufw allow out 53
/usr/sbin/ufw allow out 80
/usr/sbin/ufw allow out 443
/usr/sbin/ufw allow out 2222
/usr/sbin/ufw allow 22
/usr/sbin/ufw allow 12345
/usr/sbin/ufw allow 25
for cfip in `cat /tmp/ips-v4`; do /usr/sbin/ufw allow from $cfip to any port 80; done
for cfip in `cat /tmp/ips-v4`; do /usr/sbin/ufw allow from $cfip to any port 443; done
for cfip in `cat /tmp/ips-v6`; do /usr/sbin/ufw allow from $cfip to any port 80; done
for cfip in `cat /tmp/ips-v6`; do /usr/sbin/ufw allow from $cfip to any port 443; done
/sbin/iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A OUTPUT -p icmp --icmp-type 8 -s 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
/usr/sbin/ufw --force enable

/usr/sbin/ufw reload
~                                                                     
