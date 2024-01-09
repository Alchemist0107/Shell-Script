!/bin/bash

##named 서비스 중지 및 확인 
#
#systemctl stop named
#systemctl status named
#if [ $? -eq 0 ]; then 
#	echo "named 서비스가 성공적으로 중지되었습니다."
#else 
#	echo "named 서비스 중지 실패"
#	exit 1
#fi 

#
##부팅시 자동 시작 설정 헤제 
#systemctl disable named 
#if [ $? -eq 0 ]; then 
#	echo "named 서비스가 부팅 시 자동 시작에서 성공적으로 제거되었습니다."
#else 
#	echo "부팅 시 자동 시작에서 named 제거 실패"
#	exit 1
#fi

#패키지 제거 
yum remove bind bind-chroot -y
if [ $? -eq 0 ]; then 
	echo "named 패키지가 성공적으로 제거되었습니다."
else
	echo "named 패키지 제거 실패"
	exit 1
fi

#설정 파일 제거 
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

 
