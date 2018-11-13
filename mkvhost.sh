#!/bin/bash

################ install httpd ##################

systemctl start httpd > /dev/null 2>&1

if [ $? -ne 0 ]; then
	yum -y install httpd &> /dev/null
	systemctl enable httpd &> /dev/null
	systemctl start httpd &> /dev/null
	echo "Http successful installation"
else
  systemctl enable httpd &> /dev/null
fi


################# mkvhost #####################

# Variables

VHOSTNAME=$1
TIER=$2
HTTPDCONF=/etc/httpd/conf/httpd.conf
VHOSTCONFDIR=/etc/httpd/conf.vhosts.d
DEFVHOSTCONFFILE=$VHOSTCONFDIR/00-default-vhost.conf
VHOSTCONFFILE=$VHOSTCONFDIR/$VHOSTNAME.conf
WWWROOT=/var/www
DEFVHOSTDOCROOT=$WWWROOT/default/www
VHOSTDOCROOT=$WWWROOT/$VHOSTNAME/www

# check arguments

if [ "$VHOSTNAME" = '' ] || [ "$TIER" = '' ]; then
	echo "Usage: $0 VHOSTNAME TIER"
	exit 1

else

# Set support email address
	case $TIER in
		1)	VHOSTADMIN='basic_support@example.com'
			;;
		2)	VHOSTADMIN='business_support@example.com'
			;;
		3)	VHOSTADMIN='enterprise_support@example.com'
			;;
		*)	echo "Invalid tier specified"
			exit 1
			;;
	esac

fi

# Create conf directory one time if non-exittent

if [ ! -d $VHOSTCONFDIR ]; then
	mkdir $VHOSTCONFDIR

	if [ $? -ne 0 ]; then
		echo "ERROR: Failed creating $VHOSTCONFDIR."
		exit 1
	fi

fi

# Add include one time if missing
grep -q '^IncludeOptional conf\.vhosts\.d/\*\.conf$' $HTTPDCONF

if [ $? -ne 0 ]; then
	#Backup before modifying
	cp -a $HTTPDCONF $HTTPDCONF.orig
	
	echo "IncludeOptional conf.vhosts.d/*.conf" >> $HTTPDCONF

	if [ $? -ne 0 ]; then
		echo "ERROR: Failed adding include directive."
		exit 1
	fi

fi

# Check for default virtual host
if [ ! -f $DEFVHOSTCONFFILE ]; then
	cat <<DEFCONFEOF > $DEFVHOSTCONFFILE
<VirtualHost _default_:80>
  DocumentRoot $DEFVHOSTDOCROOT
  Customlog "logs/default-vhost.log" combined
</VirtualHost>

<Directory $DEFVHOSTDOCROOT>
  Require all granted
</Directory>
DEFCONFEOF
fi

if [ ! -d $DEFVHOSTDOCROOT ]; then
	mkdir -p $DEFVHOSTDOCROOT
	restorecon -Rv /var/www	
fi

# Check for virtual host conflict
if [ -f $VHOSTCONFFILE ]; then
	echo "ERROR: $VHOSTCONFFILE already exists."
	exit 1
elif [ -d $VHOSTDOCROOT ]; then
	echo "ERROR: $VHOSTDOCROOT already exists."
	exit 1
else
	cat <<CONFEOF > $VHOSTCONFFILE
<Directory $VHOSTDOCROOT>
  Require all granted
  AllowOverride None
</Directory>

<VirtualHost *:80>
  DocumentRoot $VHOSTDOCROOT
  ServerName $VHOSTNAME
  ServerAdmin $VHOSTADMIN
  ErrorLog "logs/${VHOSTNAME}_error_log"
  CustomLog "logs/${VHOSTNAME}_access_log" common
</VirtualHost>
CONFEOF


	mkdir -p $VHOSTDOCROOT
	restorecon -Rv $WWWROOT
fi

# Check config and reload
apachectl configtest &> /dev/null

if [ $? -eq 0 ]; then
	systemctl reload httpd &> /dev/null
	echo "$VHOSTNAME created successfully"
else
	echo "ERROR: Config error."
	exit 1
fi
