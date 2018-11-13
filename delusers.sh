#!/bin/bash
for line in $(cat /root/userlist)
do
	userdel -r $line
done
