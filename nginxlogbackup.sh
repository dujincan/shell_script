#!/bin/bash
# var
log_path=/usr/local/nginx/logs
backup_path=/usr/local/nginx/logs/log
date=$(date +%Y-%m-%d-%H-%M)

# mv old log file
mv ${nginx_log_path}/access.log ${backup_path}/access_${date}.log
mv ${nginx_log_path}/error.log ${backup_path}/error_${date}.log
kill -USR1 $(cat /usr/local/nginx/logs/nginx.pid)

# delete before 30 day
find ${backup_path} -name "*.log" -mtime +30 -exec rm -rf {} \;
