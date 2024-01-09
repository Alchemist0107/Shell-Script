#!/bin/bash 

#
#DNS 설치 스크립트
# 
function install_dns() {
echo "DNS 서버 설치를 시작합니다..."

#
#DNS 서버에 필요한 패키지 설치 
#
yum install -y bind bind-chroot

#패키지 설치후 네임서버 1.1.1.1 제거
sed -i '1s/^nameserver 1.1.1.1//' /etc/resolv.conf


#사용자로부터 DNS 서버의 IP 주소와 도메인 서비스 정보 입력 하기
read -p "DNS 서버 IP 주소를 입력해주세요:" dns_ip
read -p "사용할 도메인을  입력해주세요:" domain_name
read -p "도메인의 IP 주소를 입력:" domain_ip
read -p "설정할 서비스를 입력해주세요:" service_name

# /etc/resolv.conf 설정
echo "nameserver $dns_ip" > /etc/resolv.conf

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
sed -i "\$a\
\
zone \"$domain_name\" IN {\
       type master;\
       file \"$domain_name.zone\";\
       allow-update { none; }; \
};" /etc/named.rfc1912.zones

after_rfc1912_zones=$(cat /etc/named.rfc1912.zones)

#
#zone 파일의 규칙 및 도메인의 연결할 IP 레코드를 추가한다
#
touch /var/named/$domain_name.zone
chown root:named /var/named/$domain_name.zone

#
#존 파일 경로 지정 
#
zoneFilePath="/var/named/$domain_name.zone"

#
#존 파일 생성 
#
tee "$zoneFilePath" > /dev/null <<EOF
\$TTL $TTL 1D
@       IN SOA  $domain_name. root. (
				0       ; serial
				1D      ; refresh
				1H      ; retry
				1W      ; expire
				1D )    ; minimum
	IN	NS      $domain_name.
	IN	A       $domain_ip
$service_name        IN	A       $domain_ip
EOF

#
#named 체크가 잘 되어있는지 확인 
#
named-checkzone_result=$(named-checkzone "$domain_name.zone" "$zoneFilePath")

#
#시스템 재시작 
#
systemctl start named
systemctl_status_named=$(systemctl status named)


#
#nslookup 으로 확인 
#
nslookup_resul=$(nslookup www.$domain_name)


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

echo "DNS 서버 설치를 완료했습니다..."
}

remove_dns() {
echo "DNS 서버를 제거합니다..."
#
#패키지 제거
#
yum remove bind bind-chroot -y
if [ $? -eq 0 ]; then
	echo "named 패키지가 성공적으로 제거되었습니다."
else
	echo "named 패키지 제거 실패"
	exit 1
fi

#
#설정 파일 제거
#
read -p "설정 파일과 데이터를  제거하시겠습니까? (y/n):" response
if [ "$response" = "y" ]; then
	rm -rf /etc/named
	rm -rf /var/named
	echo "설정 파일과 데이터가 제거되었습니다."
else
	echo "설정 파일과 데이터 제거가 취소되었습니다."
fi

#/etc/resolv.conf 복귀
echo "nameserver 1.1.1.1" > /etc/resolv.conf

echo "DNS 서버 제거를 완료했습니다..."
}

#
#DNS서버 설치 & 제거 반복문 설정 
#
while true; do 
	install_dns
	while true; do
		read -p "DNS 서버를제거하겠습니까? (y/n):" remove_choice
		case "$remove_choice" in
		 y)
	         	remove_dns
		 	brek
		 	;;
		n)
		  	break
		  	;;
		*)
	          echo "잘못 입력하셨습니다 'y','n'."
                  ;;
	esac
done

#
#제거 후 다시 DNS 서버 설치를 묻는 부분 
#
read -p "다시 설치하시겠습니까 (y/n)?" choice
case "$choice" in
   [Nn]*) break ;;
esac
done
