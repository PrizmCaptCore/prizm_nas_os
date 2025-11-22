# NAS OS Networking Guide

NAS OS includes advanced networking features that go beyond traditional NAS systems, providing router-grade capabilities for home and enterprise use.

## Quick Start

Run the interactive network configuration tool:
```bash
sudo nas-network
```

## Core Networking Features

### 1. Advanced Network Interface Management

Configure interfaces with static IP or DHCP:

```bash
# Static IP
nmcli con add type ethernet con-name static-eth0 ifname eth0 \
  ip4 192.168.1.100/24 gw4 192.168.1.1

# Add DNS servers
nmcli con mod static-eth0 ipv4.dns "8.8.8.8,8.8.4.4"

# Activate
nmcli con up static-eth0
```

### 2. VLAN Support

Create and manage VLANs for network segmentation:

```bash
# Create VLAN 10 on eth0
nmcli con add type vlan con-name vlan10 ifname eth0.10 \
  dev eth0 id 10 ip4 192.168.10.1/24

# Or using ip command
ip link add link eth0 name eth0.10 type vlan id 10
ip addr add 192.168.10.1/24 dev eth0.10
ip link set dev eth0.10 up
```

**Use Cases:**
- Separate guest network
- IoT device isolation
- Management network
- Multi-tenant environments

### 3. Network Bridges

Create bridges for VMs and containers:

```bash
# Create bridge
nmcli con add type bridge con-name br0 ifname br0

# Add interfaces to bridge
nmcli con add type bridge-slave con-name br0-eth0 ifname eth0 master br0
nmcli con add type bridge-slave con-name br0-eth1 ifname eth1 master br0

# Activate bridge
nmcli con up br0
```

**Use Cases:**
- VM networking
- Container networking
- Link aggregation
- Network failover

## VPN Server

### WireGuard VPN

Modern, fast, and secure VPN solution.

#### Setup

Use the interactive tool:
```bash
sudo nas-network
# Select option 4: Set Up VPN Server (WireGuard)
```

Or manually:

```bash
# Generate server keys
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key

# Create config
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $(cat /etc/wireguard/server_private.key)

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
EOF

# Enable and start
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Open firewall
ufw allow 51820/udp
```

#### Client Configuration

```ini
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = your.nas.ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

### OpenVPN

Traditional, widely supported VPN solution.

```bash
# Install easy-rsa
sudo pacman -S easy-rsa

# Initialize PKI
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
./easyrsa build-ca
./easyrsa gen-dh
./easyrsa build-server-full server nopass
./easyrsa build-client-full client1 nopass

# Generate TLS key
openvpn --genkey secret ta.key

# Create server config in /etc/openvpn/server/server.conf
```

## DHCP/DNS Server

### dnsmasq Setup

Provide DHCP and DNS services for your network:

```bash
# Edit /etc/dnsmasq.conf
interface=eth0
dhcp-range=192.168.1.100,192.168.1.200,24h
dhcp-option=option:router,192.168.1.1
dhcp-option=option:dns-server,192.168.1.1

# Local domain
domain=nas.local
expand-hosts

# Upstream DNS
server=8.8.8.8
server=8.8.4.4

# Static leases
dhcp-host=aa:bb:cc:dd:ee:ff,192.168.1.50,desktop

# Enable and start
systemctl enable dnsmasq
systemctl start dnsmasq
```

### Custom DNS Records

```bash
# Add to /etc/dnsmasq.conf
address=/nas.local/192.168.1.100
address=/media.nas.local/192.168.1.100
address=/cloud.nas.local/192.168.1.100

# Restart
systemctl restart dnsmasq
```

## Advanced Routing

### Static Routes

```bash
# Add route
ip route add 10.0.0.0/8 via 192.168.1.254 dev eth0

# Make persistent with NetworkManager
nmcli con mod eth0 +ipv4.routes "10.0.0.0/8 192.168.1.254"
```

### Policy-Based Routing

```bash
# Create routing table
echo "200 vpn" >> /etc/iproute2/rt_tables

# Add rule
ip rule add from 192.168.1.0/24 table vpn
ip route add default via 10.0.0.1 table vpn
```

### FRRouting (Advanced)

For BGP, OSPF, and other dynamic routing protocols:

```bash
# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Configure FRR
vtysh
configure terminal
router ospf
network 192.168.1.0/24 area 0
exit
exit
write
```

## Firewall and NAT

### nftables (Recommended)

```bash
# Create NAT rule
nft add table nat
nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule nat postrouting oifname "eth0" masquerade

# Port forwarding
nft add chain nat prerouting { type nat hook prerouting priority -100 \; }
nft add rule nat prerouting iifname "eth0" tcp dport 8080 dnat to 192.168.1.10:80

# Save rules
nft list ruleset > /etc/nftables.conf
systemctl enable nftables
```

### iptables

```bash
# Enable NAT/masquerading
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Port forwarding
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 -j DNAT --to-destination 192.168.1.10:80
iptables -A FORWARD -p tcp -d 192.168.1.10 --dport 80 -j ACCEPT

# Save rules
iptables-save > /etc/iptables/iptables.rules
systemctl enable iptables
```

### UFW (User-Friendly)

```bash
# Enable
ufw enable

# Allow services
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

# Port forwarding
ufw route allow proto tcp from any to 192.168.1.10 port 80

# NAT (edit /etc/ufw/before.rules)
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o eth0 -j MASQUERADE
COMMIT
```

## Load Balancing

### HAProxy

Distribute traffic across multiple servers:

```bash
# Edit /etc/haproxy/haproxy.cfg
frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    server server1 192.168.1.10:80 check
    server server2 192.168.1.11:80 check
    server server3 192.168.1.12:80 check

# Enable and start
systemctl enable haproxy
systemctl start haproxy
```

### Web Interface (HAProxy Stats)

```bash
# Add to haproxy.cfg
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
```

Access at: `http://nas-ip:8404/stats`

## Proxy and Caching

### Squid Proxy

```bash
# Edit /etc/squid/squid.conf
http_port 3128

# ACL for local network
acl localnet src 192.168.1.0/24
http_access allow localnet

# Cache settings
cache_dir ufs /var/spool/squid 10000 16 256

# Enable and start
systemctl enable squid
systemctl start squid
```

## Network Monitoring

### Real-Time Monitoring

```bash
# Bandwidth by interface
iftop -i eth0

# Bandwidth by process
sudo nethogs eth0

# Connection monitoring
bmon

# Live network stats
vnstat -l -i eth0
```

### Long-Term Statistics

```bash
# Initialize vnstat database
vnstat -u -i eth0

# View stats
vnstat                    # Summary
vnstat -h                 # Hourly
vnstat -d                 # Daily
vnstat -m                 # Monthly
vnstat -l                 # Live mode
```

### Connection Tracking

```bash
# Active connections
ss -tunap

# Connection statistics
ss -s

# Watch connections
watch -n1 'ss -tunap'

# Network flow analysis
nft monitor
```

## QoS (Quality of Service)

### Traffic Shaping with tc

```bash
# Limit interface bandwidth to 10 Mbps
tc qdisc add dev eth0 root tbf rate 10mbit burst 32kbit latency 400ms

# Priority queuing
tc qdisc add dev eth0 root handle 1: htb default 30
tc class add dev eth0 parent 1: classid 1:1 htb rate 100mbit

# High priority (VoIP, gaming)
tc class add dev eth0 parent 1:1 classid 1:10 htb rate 50mbit ceil 80mbit prio 1

# Low priority (bulk downloads)
tc class add dev eth0 parent 1:1 classid 1:30 htb rate 20mbit ceil 60mbit prio 3

# Match traffic
tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32 \
  match ip sport 22 0xffff flowid 1:10
```

## Network Security

### Fail2ban Integration

```bash
# Monitor SSH attacks
[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

# Monitor web attacks
[nginx-limit-req]
enabled = true
filter = nginx-limit-req
logpath = /var/log/nginx/error.log
```

### Port Knocking

```bash
# Install knockd
pacman -S knock

# Edit /etc/knockd.conf
[options]
    UseSyslog

[openSSH]
    sequence    = 7000,8000,9000
    seq_timeout = 5
    command     = /usr/bin/iptables -A INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn

# Enable
systemctl enable knockd
```

## Troubleshooting

### Network Diagnostics

```bash
# Test connectivity
ping -c 4 8.8.8.8
mtr google.com

# DNS testing
nslookup google.com
dig google.com

# Route testing
traceroute google.com

# Speed test
iperf3 -c iperf.he.net

# Port scanning
nmap -p 1-1000 192.168.1.1

# Packet capture
tcpdump -i eth0 -w capture.pcap
```

### Performance Testing

```bash
# Bandwidth between two hosts
# On server:
iperf3 -s

# On client:
iperf3 -c server-ip

# Network throughput
dd if=/dev/zero bs=1M count=1000 | ssh user@host 'cat > /dev/null'
```

## Configuration Examples

### Home Router Replacement

```bash
# WAN interface: eth0 (DHCP from ISP)
# LAN interface: eth1 (Static 192.168.1.1)

# LAN setup
nmcli con add type ethernet con-name LAN ifname eth1 \
  ip4 192.168.1.1/24

# Enable NAT
nft add table nat
nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule nat postrouting oifname "eth0" masquerade

# DHCP server
# /etc/dnsmasq.conf:
interface=eth1
dhcp-range=192.168.1.100,192.168.1.250,12h

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
```

### Multi-WAN Load Balancing

```bash
# Create routing tables
echo "1 wan1" >> /etc/iproute2/rt_tables
echo "2 wan2" >> /etc/iproute2/rt_tables

# Add routes
ip route add default via 192.168.1.1 dev eth0 table wan1
ip route add default via 192.168.2.1 dev eth1 table wan2

# Load balancing
ip route add default scope global \
  nexthop via 192.168.1.1 dev eth0 weight 1 \
  nexthop via 192.168.2.1 dev eth1 weight 1
```

### Guest Network Isolation

```bash
# Create guest VLAN
nmcli con add type vlan con-name guest ifname eth0.100 \
  dev eth0 id 100 ip4 192.168.100.1/24

# DHCP for guests
# /etc/dnsmasq.conf:
interface=eth0.100
dhcp-range=192.168.100.100,192.168.100.200,2h

# Block access to LAN
iptables -A FORWARD -i eth0.100 -o eth1 -j DROP
iptables -A FORWARD -i eth0.100 -o eth0 -j ACCEPT
```

## Best Practices

1. **Security First**
   - Change default passwords
   - Use strong encryption for VPNs
   - Keep firewall rules minimal and documented
   - Regular security updates

2. **Performance**
   - Enable hardware offloading when available
   - Use appropriate MTU sizes
   - Monitor bandwidth usage
   - Implement QoS for critical services

3. **Reliability**
   - Document all configurations
   - Test changes in non-production first
   - Keep backups of working configs
   - Monitor logs regularly

4. **Monitoring**
   - Set up alerts for high bandwidth
   - Monitor VPN connections
   - Track firewall blocks
   - Regular speed tests

## Additional Resources

- [Arch Wiki - Network Configuration](https://wiki.archlinux.org/title/Network_configuration)
- [WireGuard Documentation](https://www.wireguard.com/)
- [nftables Wiki](https://wiki.nftables.org/)
- [HAProxy Documentation](http://www.haproxy.org/#docs)
- [FRRouting Documentation](https://docs.frrouting.org/)

---

For interactive configuration, use:
```bash
sudo nas-network
```
