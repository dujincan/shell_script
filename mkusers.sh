#!/bin/bash
for line in $(cat /root/userlist)
do
	useradd -s /bin/bash $line
	echo $line | passwd --stdin $line
	chage -d 0 $line
	echo "$line successfully created."
done
