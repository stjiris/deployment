# proxmox

Documentation for the configuration of the host OS


### VM Networking: Masquerading (NAT) with iptables

```
$ cp etc/network/interfaces /etc/network/interfaces
# Edit as needed
$ ifreload -a
```

### NTP Server

```
$ apt install ntp
```

### VM DHCP server

```
$ apt install dnsmasq dnsutils
$ cp etc/dnsmasq.conf /etc/
$ systemctl restart dnsmasq
```


