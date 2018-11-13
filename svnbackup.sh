#!/bin/bash

log="/data/svnbak/last_add_backed_up.log"   # 添加日志文件，打印开始结束时间，方便查看执行时间
echo "********************"backup start time: `date -d today +"%Y-%m-%d %T"`"***************">> $log

cd /data/svnbak
mkdir `date +%F`
chmod 755 `date +%F`
cd  `date +%F`
ls -l /home/svn-repos | awk '$1~"d"{print$8}' > list #注：/home/svn-repos是svn数据库的路径


for i in `cat list`
do
    mkdir /data/svnbak/`date +%F`/$i #注：在另一个路径下创建与数据库相同的目录
done


SRCPATH=/home/svn-repos #定义仓库路径
DISTPATH=/data/svnbak/`date +%F`  #定义备份数据存放的路径;
echo $DISTPATH
cat $DISTPATH/list | while read filename
do
    svnadmin hotcopy $SRCPATH/$filename  $DISTPATH/$filename --clean-logs #注：此处使用hotcopy开始备份
done


echo "-------------------backup end time: \"`date -d today +\"%Y-%m-%d %T\"`\"-------------------" >> $log


chown www-data.www-data $DISTPATH -R #注：备份之后修改成与原数据库相同的权限


#删除10天前的备份
basedir=/data/svnbak/ #备份的路径
old_day=`date +%F -d"-10 days"`
filename=$basedir/$old_day
rm -rf $filename
