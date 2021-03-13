# no empty lines are allowed - causes error in parser
#
OVPN_DATA="/some/patch/to/waht/is/mapped/to/docker/container/opt/openvpn-core/"
if [ -z "$OVPN_FQDN" ] || [ -z "$OVPN_DATA" ] || [ -z "$OVPN_NET" ]; then
    source ../.env.tmp
    if [ -z "$OVPN_FQDN" ] || [ -z "$OVPN_DATA" ] || [ -z "$OVPN_NET" ]; then
        echo "###################### Bombing out as no OVPN_FQDN is provided"
        exit 1
    fi
fi
docker run --rm  -e DEBUG=true -v ${OVPN_DATA}:/etc/openvpn \
  -p 1196:1194/udp --cap-add=NET_ADMIN \
  local/openvpn-v8 \
  ovpn_genconfig \
  -u "$OVPN_FQDN" \
  -d -z \
  -n "172.20.0.5" \
  -a SHA512 \
  -C AES-256-CBC \
  -T "TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH" \
  -s "$OVPN_NET" \
  -e "# openvpn-ui required
log         /etc/openvpn/openvpn.log
management 0.0.0.0 2080
#
# TLS Security
tls-version-min 1.2
#
#Enable multiple clients to connect with the same certificate key
duplicate-cn
#
# not really something we want as it will keep prompting for username/pass? - to be checked
# auth-nocache
#
# not really needed as we will have ccd allocated IPs
# ifconfig-pool-persist ipp.txt
# keepalive 10 60
#
# going to be deprecated in 2.6
# keysize 256
#
# max-clients 100
mute 10"
