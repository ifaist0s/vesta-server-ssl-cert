# vesta-server-ssl-cert
A Linux shell script for [VESTA Control Panel](https://vestacp.com/) to assign correct SSL certificate to all services (vesta, exim, etc)

### The problem
VESTA has included support for the free and open Certificate Authority [Let’s Encrypt](https://letsencrypt.org/). It now supports automatic issuance and renewal of certificates for domain names. But there is no automatic mechanism (yet) to update the configuration of all VESTA services to use the FQDN server certificate.

### The solution
This script compares the FQDN Server certificates issued by Let's Encrypt and if they're different it places them to the correct directory with the correct name.
