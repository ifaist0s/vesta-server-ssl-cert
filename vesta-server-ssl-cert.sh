#!/bin/bash
# info: check SSL certificates
# options: NONE
#
# The script checks for new LetsEncrypt certificates in /home/admin/conf/web/ssl.[SERVER-FQDN].*
# and it installs the new certificates for all services before restarting them.

# Set the paths of SSL certificates to check
path2le=/home/admin/conf/web
path2ve=/usr/local/vesta/ssl

# Certificates to check
LEcrt="${path2le}/ssl."$(hostname -f)".crt"
LEkey="${path2le}/ssl."$(hostname -f)".key"
LEpem="${path2le}/ssl."$(hostname -f)".pem"
VEcrt="${path2ve}/certificate.crt"
VEkey="${path2ve}/certificate.key"
VEpem="${path2ve}/certificate.pem"

# Compare current certificate with auto generated ones from LetsEncrypt
if ! cmp --silent $LEcrt $VEcrt
then
	echo CERTIFICATES DIFFERENT - UPDATING
	# Copy certificates
	cp --backup $LEcrt $VEcrt
	cp --backup $LEkey $VEkey
	cp --backup $LEpem $VEpem

	# Set correct owner and permissions for certificates
	chown root:mail $VEcrt $VEkey
	chmod 660 $VEcrt $VEkey

	# Restart services that depend on these certificates
	systemctl restart vesta exim dovecot vsftpd
fi
