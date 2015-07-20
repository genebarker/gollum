#!/bin/bash
set -e
echo "gollum - a Gollum webapp on Debian 8 Docker Container"

GROOT="/root/wiki"
OLDKEY="/root/oldfiles/ssl-cert-snakeoil.key"
OLDCERT="/root/oldfiles/ssl-cert-snakeoil.pem"
SSLKEY="/etc/ssl/private/ssl-cert-snakeoil.key"
SSLCERT="/etc/ssl/certs/ssl-cert-snakeoil.pem"

if [ "$#" != "0" ]; then
    CMD="$1"
    if [ "$CMD" == '--http' ]; then
        echo "run Gollum using plain HTTP..."
        # set HTTP proxy to gollum server
        sed -i "s/DocumentRoot \/var\/www\/html.*/ProxyPass \/ http:\/\/localhost:4567\/\n\tProxyPassReverse \/ http:\/\/localhost:4567\//" /etc/apache2/sites-available/000-default.conf
	# enable proxy mod
        a2enmod proxy_http
        # start apache
        apache2ctl start
        # consume 1st arg (the rest are gollum's)
        shift
	# determine startup type
        if [ -z "$RACK_APP" ]; then
            # start gollum using provided arg's
	    cd $GROOT
            exec gollum "$@"
            exit
        else
            # start as rack app
            cd $GROOT
            exec rackup $RACK_APP -p 4567
            exit
        fi
    elif [ "$CMD" == '--hsts' ]; then
        echo "run Gollum using HTTPS only..."
        if [ "$#" == "1" ]; then
            echo "error: no FQDN provided."
            exit 1
        fi
        FQDN="$2"
        # check if new key and cert needed
        set +e
        cmp $OLDKEY $SSLKEY > /dev/null
        SAMEKEY=$?
        cmp $OLDCERT $SSLCERT > /dev/null
        SAMECERT=$?
        set -e
        if [[ $SAMEKEY -eq 0 ]] || [[ $SAMECERT -eq 0 ]]; then
            # create new self-signed secure ones
            openssl genrsa -out $SSLKEY 2048
            openssl req -new -x509 -sha256 -days 3653 -key $SSLKEY -out $SSLCERT -subj "/CN=$FQDN"
        fi
        # set apache ServerName globally
        sed -i "/# Global configuration/a ServerName $FQDN" /etc/apache2/apache2.conf
        # set accepetable SSL ciphers
        sed -i 's/SSLCipherSuite HIGH:!aNULL.*/SSLCipherSuite ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS/' /etc/apache2/mods-available/ssl.conf
        # set to redirect HTTP to HTTPS (HSTS Strict Transport Security)
        sed -i "s/DocumentRoot \/var\/www\/html.*/Redirect permanent \/ https:\/\/$FQDN\//" /etc/apache2/sites-available/000-default.conf
	# enable SSL
        a2enmod ssl
	# set HTTPS proxy to gollum server
        sed -i "s/DocumentRoot \/var\/www\/html.*/ProxyPass \/ http:\/\/localhost:4567\/\n\tProxyPassReverse \/ http:\/\/localhost:4567\//" /etc/apache2/sites-available/default-ssl.conf
        # enable proxy mod
        a2enmod proxy_http
        # enable SSL site
        ln -sf /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf
        # start apache
        apache2ctl start
        # consume 1st 2 arg's (the rest are gollum's)
        shift 2
	# determine startup type
        if [ -z "$RACK_APP" ]; then
            # start gollum using provided arg's
	    cd $GROOT
            exec gollum "$@"
            exit
        else
            # start as rack app
            cd $GROOT
            exec rackup $RACK_APP -p 4567
            exit
        fi
    elif [ $CMD == '--help' ]; then
        echo "show help"
    else
        exec "$@"
        exit
    fi
fi

echo
echo "usage: genebarker/gollum [OPTION]"
echo
echo "The available OPTIONs are:"
echo "   --http [GOLLUMOPTION]...       Run Gollum using plain HTTP"
echo "   --hsts FQDN [GOLLUMOPTION]...  Run Gollum using HTTPS only"
echo "          (must provide FQDN, i.e. mybox.example.com)"
echo "   --help                         Display this message"
echo
echo "To use wiki repository on the host, mount it, i.e.:"
echo "   $ docker run -d -p 80:80 \\"
echo "       -v /home/me/wiki:/root/wiki \\"
echo "       genebarker/gollum --http"
echo
echo "To run with strict HTTPS creating new self-signed keys:"
echo "   $ docker run -d -p 80:80 -p 443:443 \\"
echo "       genebarker/gollum --hsts mybox.example.com"
echo
echo "To run with strict HTTPS using your own keys, mount them, i.e.:"
echo "   $ docker run -d -p 80:80 -p 443:443 \\"
echo "       -v /etc/ssl:/etc/ssl \\"
echo "       genebarker/gollum --hsts mybox.example.com"
echo
echo "   (the cert's CN must match the FQDN)"
echo
echo "To run as a rack application, place your config file in the repo,"
echo "mount it, and set the RACK_APP environment variable to its name:"
echo "   $ docker run -d -p 80:80 \\"
echo "       -v /home/me/wiki:/root/wiki \\"
echo "       -e RACK_APP=config.ru \\"
echo "       genebarker/gollum --http"
echo
echo "To bypass script, just enter desired command, i.e.:"
echo "   $ docker run -it genebarker/gollum bash"
echo
echo "Key paths in the container:"
echo "   /root/wiki     - Wiki content (a git repository)"
echo "   /etc/ssl       - SSL keys and certificates"
echo "   /etc/ssl/private/ssl-cert-snakeoil.key  - Private SSL key"
echo "   /etc/ssl/certs/ssl-cert-snakeoil.pem    - Public SSL cert"

exit 0
