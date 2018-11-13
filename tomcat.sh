#!/bin/bash
usage () {
    echo "Usage: $0 [start|stop|status]"
}

status_tomcat () {

ps -aux | grep java | grep tomcat | grep -v 'grep'

}

start_tomcat () 
{
/usr/local/tomcat/bin/startup.sh

}

stop_tomcat () {

TPID=$(ps -aux | grep java | grep tomcat | grep -v 'grep' | awk '{print $2}')
kill -9 $TPID
sleep 5;

TSTAT=$(ps -aux | grep java | grep tomcat | grep -v 'grep' | awk '{print $2}')
     if [ -z $TSTAT ];then
       echo "tomcat stop"
     else
       kill -9 $TSTAT
     fi

}


main () {
case $1 in
	start)
		start_tomcat;;
	stop)
		stop_tomcat;;
        status)
		status_tomcat;;
	*)
		usage;;
esac
}

main $1
