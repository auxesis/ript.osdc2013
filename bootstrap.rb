partition "bootstrap" do
  raw <<-RAW
####################
#      policy      #
####################
iptables --policy INPUT DROP
iptables --policy FORWARD DROP
iptables --policy OUTPUT ACCEPT
iptables --table mangle --policy PREROUTING ACCEPT
iptables --table mangle --policy OUTPUT ACCEPT

####################
#      before      #
####################
# Clean all traffic by sending it through a "before" chain.
iptables --new-chain before-a

iptables --insert INPUT 1 --jump before-a
iptables --insert OUTPUT 1 --jump before-a
iptables --insert FORWARD 1 --jump before-a

# ICMP cleaning
iptables --append before-a --protocol ICMP --icmp-type echo-reply --jump ACCEPT
iptables --append before-a --protocol ICMP --icmp-type destination-unreachable --jump ACCEPT
iptables --append before-a --protocol ICMP --icmp-type source-quench --jump ACCEPT
iptables --append before-a --protocol ICMP --icmp-type echo-request --jump ACCEPT
iptables --append before-a --protocol ICMP --icmp-type time-exceeded --jump ACCEPT
iptables --append before-a --protocol ICMP --icmp-type parameter-problem --jump ACCEPT
iptables --append before-a --protocol ICMP --icmp-type redirect --jump ACCEPT
iptables --append before-a --protocol ICMP --jump LOG --log-prefix "INVALID_ICMP " --log-level debug
iptables --append before-a --protocol ICMP --jump DROP

# TCP cleaning
iptables --append before-a --protocol TCP --tcp-flags ALL FIN,URG,PSH -j LOG --log-prefix "BAD_NMAP-XMAS " --log-level debug
iptables --append before-a --protocol TCP --tcp-flags ALL FIN,URG,PSH -j DROP
iptables --append before-a --protocol TCP --tcp-flags SYN,FIN SYN,FIN -j LOG --log-prefix "BAD_SYN/FIN " --log-level debug
iptables --append before-a --protocol TCP --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables --append before-a --protocol TCP --tcp-flags SYN,RST SYN,RST -j LOG --log-prefix "BAD_SYN/RSFINT " --log-level debug
iptables --append before-a --protocol TCP --tcp-flags SYN,RST SYN,RST -j DROP

# State cleaning
iptables --append before-a --match state --state INVALID --jump LOG --log-prefix "INVALID_STATE " --log-level debug
iptables --append before-a --match state --state INVALID --jump DROP
iptables --append before-a --protocol TCP --match state --state ESTABLISHED,RELATED --jump ACCEPT
iptables --append before-a --protocol UDP --match state --state ESTABLISHED,RELATED --jump ACCEPT

# Allow loopback
iptables --insert before-a --protocol ALL --in-interface lo --jump ACCEPT
iptables --insert before-a --protocol ALL --out-interface lo --jump ACCEPT

# Tag packets so iproute2 knows which interface it should send replies via
iptables --table mangle --append PREROUTING --jump CONNMARK --restore-mark
#
# XXX UPDATE THIS TO YOUR EXTERNAL VLAN XXX
iptables --table mangle --append PREROUTING --in-interface vlan35 --jump MARK --set-mark 35
iptables --table mangle --append PREROUTING --in-interface vlan33 --jump MARK --set-mark 33
iptables --table mangle --append PREROUTING --in-interface vlan32 --jump MARK --set-mark 32
iptables --table mangle --append PREROUTING --in-interface vlan31 --jump MARK --set-mark 31
# iptables --table mangle --append PREROUTING --in-interface vlanXXXy --jump MARK --set-mark XXXy
#
iptables --table mangle --append POSTROUTING --jump CONNMARK --save-mark

####################
#      after       #
####################
# Clean all traffic by sending it through an "after" chain.
iptables --new-chain after-a

iptables --table filter --append INPUT --jump after-a
iptables --table filter --append OUTPUT --jump after-a
iptables --table filter --append FORWARD --jump after-a

iptables --append after-a --jump LOG --log-prefix "END_DROP " --log-level debug
  RAW
end
