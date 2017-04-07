#!/bin/bash
# info: check SSL certificates
# options: NONE
#
# The script checks for new LetsEncrypt certificates in /home/admin/conf/web/ssl.[SERVER-FQDN].*
# and it installs the new certificates for all services before restarting them.

# Notification email parameters
mailto='CHANGE_THIS TO YOUR EMAIL ADDRESS'
mailsub="Server SSL Renewal: "$(hostname -f)

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
	case $(head -n1 /etc/issue | cut -f 1 -d ' ') in
		Debian)
			type="debian" ;;
		Ubuntu)
			service vesta restart
			service exim4 restart
			service dovecot restart
			service vsftpd restart
			;;
		*)
			systemctl restart vesta exim dovecot vsftpd
			;;
	esac
	
	# Notify
	which mail > /dev/null 2>&1 && echo "The server certificate at "$(hostname -f)" has been renewed successfully :)" | mail -s "$mailsub" "$mailto"
fi
