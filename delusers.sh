#!/bin/bash
# jason at 2018 11 10
for line in $(cat /root/userlist)
do
	userdel -r $line
done
