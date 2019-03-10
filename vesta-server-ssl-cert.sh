#!/bin/bash
# info: check SSL certificates
# options: NONE
#
# The script checks for new LetsEncrypt certificates in /home/admin/conf/web/ssl.[SERVER-FQDN].*
# and it installs the new certificates for all services before restarting them.

# Notification email parameters
mailto='CHANGE THIS TO YOUR EMAIL ADDRESS'
mailsub="Server SSL Renewal: "$(hostname -f)

# Set the paths of SSL certificates to check
path2le=/home/admin/conf/web
path2ve=/usr/local/vesta/ssl
path2sq=/etc/mysql

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
	# Copy certificates for VESTA use
	cp --backup $LEcrt $VEcrt
	cp --backup $LEkey $VEkey
	cp --backup $LEpem $VEpem
	# Set owner and permissions for mail user
	chown root:mail $VEcrt $VEkey $VEpem
	chmod 640 $VEcrt $VEkey $VEpem
	
	# Copy certificates for MySQL use
	cp $VEcrt $path2sq
	cp $VEkey $path2sq
	cp $VEpem $path2sq
	# Set owner and permissions for mysql user
	chown root:mysql $path2sq/certificate.*
	chmod 640 $path2sq/certificate.*

	# Restart services that depend on these certificates
	case $(head -n1 /etc/issue | cut -f 1 -d ' ') in
		Debian)
			case $(lsb_release -s -r) in
				9.8)
					systemctl restart vesta exim4 dovecot vsftpd mysql
					;;
				*)
					echo UNKNOWN DEBIAN RELEASE. Restart services manualy.
					;;
			esac
			;;
		Ubuntu)
			case $(lsb_release -s -r) in
				16.04)
					systemctl restart vesta exim4 dovecot vsftpd mysql
					;;
				14.04)
					/usr/sbin/service vesta restart
					/usr/sbin/service exim4 restart
					/usr/sbin/service mysql restart
					/usr/bin/doveadm reload
					/sbin/initctl restart vsftpd
					;;

				*)
					echo UNKNOWN UBUNTU RELEASE. Restart services manualy.
					;;
			esac
			;;
		*)
			echo UNKNOWN OS. Restart services manualy.
			;;
	esac
	
	# Notify
	which mail > /dev/null 2>&1 && echo "The server certificate at "$(hostname -f)" has been renewed successfully :)" | mail -s "$mailsub" "$mailto"
fi
