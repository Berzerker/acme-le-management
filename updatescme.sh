#!/bin/bash

# You can use either global API key + email *OR* account ID + token
# See readme for how to use each. Account ID + Token is safer/more secure
#export CF_Key="GLOBAL_API_KEY"
#export CF_Email="EMAIL"
export CF_Account_ID="ACCOUNT_ID"
export CF_Token="TOKEN"

# Edit if you want o change the location of the acme.sh script path or cert/key drop path
ACME_PATH="$HOME/.acme.sh"
SSL_PATH="$HOME/.ssl"

DOMAIN_NAME="DOMAIN.com"
# OPTIONAL: Add multiple domains
# Add multiple -d switches to the "acme.sh --issue" command
# EX: /path/to/.acme.sh/acme.sh --issue -d  *.$DOMAIN_NAME -d $DOMAIN_NAME -d *.$DOMAIN_NAME_2 -d $DOMAIN_NAME_2 ...etc
#DOMAIN_NAME_2="DOMAIN.net"
#DOMAIN_NAME_3="DOMAIN.org"

# Change this to your provider (default Cloudflare)
DNS_PROVIDER="dns_cf"

# Change to preferred keylength (you can leave this alone)
KEY_SIZE="ec-384"

# Edit this if you have more domains to add or want to add specific sub domains. Also edit if you want to change dns provider or verification method
# Ex: -d $DOMAIN_NAME -d minecraft.$DOMAIN_NAME_2 -d *.$DOMAIN_NAME_3 --dns dns_namecheap -k 8192
$ACME_PATH/acme.sh --issue -d *.$DOMAIN_NAME -d $DOMAIN_NAME --dns $DNS_PROVIDER -k $KEY_SIZE

# This automatically drops all certs and keys in $HOME/.ssl. You can change it via the SSL_PATH variable above.
# The -d switch in this case refers to the "main" domain that gets registered (the first -d switch in the issue command above) which becomes the folder
# where acme.sh default stores all of the files. MAKE SURE the -d switch references the FIRST domain in the above --issue command.
$ACME_PATH/acme.sh --install-cert -d *.$DOMAIN_NAME --ecc \
        --cert-file $SSL_PATH/wildcard.cer \
        --key-file $SSL_PATH/wildcard.key \
        --fullchain-file $SSL_PATH/wildcard-fullchain.pem \
        --ca-file $SSL_PATH/wildcard-ca.pem \


# The following rsync lines transfer your key to a server and restart nginx automatically.
# You can remove these or comment them out if you don't need this to be done.
# Make sure your user can execute "sudo /etc/init.d/nginx restart" without needing a password
# You can google a tutorial on how to allow that.

# Edit below for username and IP of servers to transfer to
# Add more if desired using a similar format
RSYNC_1="user@ipaddress"
RSYNC_2="user2@ipaddress2"

rsync -a -e ssh $SSL_PATH/wildcard-fullchain.pem $RSYNC_1:$SSL_PATH/wildcard.cer
rsync -a -e ssh $SSL_PATH/wildcard.key $RSYNC_1:$SSL_PATH/wildcard.key

rsync -a -e $SSL_PATH/wildcard.cer $RSYNC_2:$SSL_PATH/wildcard.cer
rsync -a -e $SSL_PATH/wildcard.key $RSYNC_2:$SSL_PATH/wildcard.key
rsync -a -e $SSL_PATH/wildcard-fullchain.pem $RSYNC_2:$SSL_PATH/wildcard.fullchain

ssh -T $RSYNC_1 << EOF
sudo /etc/init.d/nginx restart
EOF

ssh -T $RSYNC_2 << EOF
sudo /etc/init.d/nginx restart
EOF

