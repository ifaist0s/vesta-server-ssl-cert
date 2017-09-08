# vesta-server-ssl-cert
A Linux shell script for [VESTA Control Panel](https://vestacp.com/) to assign and update SSL certificate to all services (vesta, exim, etc)

### The problem
VESTA has included support for the free and open Certificate Authority [Let’s Encrypt](https://letsencrypt.org/). It now supports automatic issuance and renewal of certificates for domain names. But there is no automatic mechanism (yet) to update the configuration of all VESTA services to use the FQDN server certificate.

### The solution
This script compares the FQDN Server certificates issued by Let's Encrypt and if they're different it places them to the correct directory with the correct name.

### Usage
The easiest way to use the script is with a cron job that runs every day. At the command line type `crontab -e`,  enter the line `3 3 * * * /root/vesta-server-ssl-cert.sh` and then save and exit. Take care to replace the path of the script with the correct path. Don't forget `chmod +x vesta-server-ssl-cert.sh` before running the script.

### How the script works
The script asumes that VESTA has a web domain under the admin account, which is the same as the server's FQDN, (e.g. *example.acme.com*) and has Let's Encrypt support.

By default, the implementation of Let's Encrypt in VESTA saves domain certificates at /home/[USER]/conf/web so the script checks in `/home/admin/conf/web/` for the files `ssl.[FQDN].crt`, `ssl.[FQDN].key` and `ssl.[FQDN].pem`.

In the default VESTA configuration, server certificates are found in `/usr/local/vesta/ssl` with names `certificate.crt`, `certificate.key` and `certificate.pem`.

The script checks those two sets of certificates and if different, it copies LE certificates from `/home/admin/conf/web/` to `/usr/local/vesta/ssl` overwriting the old ones, setting correct file owner and permissions and then it restarts the relevant services.

### Works with...
The script work fine in CentOS 7 and Ubuntu 14.04. **Be ware that it needs modifications to run on different OS flavors. There are issues with Ubuntu 16.04!**.
