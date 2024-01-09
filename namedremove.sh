#!/bin/bash
#yum remove bind bind-chroot
named_folder="/var/named"
if [ ! -d "$named_folder" ]; then
   echo "$named_folder 폴더가 존재하지 않습니다."
   exit 1
fi

read -p "주의: $named_folder 폴더를 삭제하시겠습니까? (y/n): " answer

if [ "$answer" != "y" ]; then
  echo "삭제가 취소되었습니다."
  exit 1
fi

rm -r "$named_folder"

echo "$named_folder 폴더가 성공적으로 삭제되었습니다."
