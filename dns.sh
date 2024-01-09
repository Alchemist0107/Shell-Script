!/bin/bash 

# /etc/resolv.conf 설정 
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 192.168.0.76" >> /etc/resolv.conf 

#
#DNS 서버에 필요한 패키지 설치 
#
yum install -y bind bind-chroot

#패키지 설치후 네임서버 1.1.1.1 제거
sed -i '1s/^nameserver 1.1.1.1//' /etc/resolv.conf



#
#현재 /etc/named.conf 파일 내용을 저장 
#
before_named_conf=$(cat /etc/named.conf)

#
#sed를 사용하여 /etc/named.conf 파일수정 
#
sed -i 's/ 127.0.0.1; /  any; /g' /etc/named.conf 
sed -i 's/ localhost; /  any; /g' /etc/named.conf
#
#수정 후 /etc/name.conf 파일 내용 저장 
#
after_named_conf=$(cat /etc/named.conf) 

#
#현재 /etc/named.rfc1912.zones 내용 저장 
#
before_rfc1912_zones=$(cat /etc/named.rfc1912.zones)

#
#DNS named.rfc1912.zones 파일 설정 
#
sed -i '$a\
\
zone "web.com" IN {\
	type master;\
	file "web.com.zone";\
	allow-update { none; }; \
};' /etc/named.rfc1912.zones

after_rfc1912_zones=$(cat /etc/named.rfc1912.zones)

#
#zone 파일의 규칙 및 도메인의 연결할 IP 레코드를 추가한다
#
touch /var/named/web.com.zone
chown root:named /var/named/web.com.zone

#
#존 파일 경로 지정 
#
zoneFilePath="/var/named/web.com.zone"

#
#존 파일 생성 
#
tee "$zoneFilePath" > /dev/null <<EOF
\$TTL $TTL 1D
@       IN SOA  web.com. root. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        1D )    ; minimum
           IN	NS      web.com.
           IN	A       192.168.0.76
www        IN	A       192.168.0.76
EOF

#
#named 체크가 잘 되어있는지 확인 
#
named-checkzone_result=$(named-checkzone web.com.zone /var/named/web.com.zone)

#
#시스템 재시작 
#
systemctl start named
systemctl_status_named=$(systemctl status named)


#
#nslookup 으로 확인 
#
nslookup_resul=$(nslookup www.web.com)


# 각각의 확인문 출력
echo "=== Checkpoints ==="
echo "Before /etc/named.conf: $before_named_conf"
echo "After /etc/named.conf: $after_named_conf"
echo "Before /etc/named.rfc1912.zones: $before_rfc1912_zones"
echo "Arter /etc/named.rfc1912.zones: $after_rfc1912_zones"
echo "named-checkzone result: $named_checkzone_result"
echo "systemctl status named: $systemctl_status_named"
echo "nslookup result: $nslookup_result"
echo "===================="
