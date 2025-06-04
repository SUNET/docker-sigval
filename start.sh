#!/bin/sh

. /luna-init.sh
KEYDIR=/etc/ssl
mkdir -p $KEYDIR/certs $KEYDIR/private
chmod og-rw $KEYDIR/private
export KEYDIR

if [ "x${CERTNAME}" = "x" ]; then
   CERTNAME="$HOSTNAME"
fi

if [ ! -f "$KEYDIR/private/${CERTNAME}.key" -o ! -f "$KEYDIR/certs/${CERTNAME}.crt" ]; then
   make-ssl-cert generate-default-snakeoil --force-overwrite
   cp /etc/ssl/private/ssl-cert-snakeoil.key "$KEYDIR/private/${CERTNAME}.key"
   cp /etc/ssl/certs/ssl-cert-snakeoil.pem "$KEYDIR/certs/${CERTNAME}.crt"
fi

CHAIN=""
if [ -f "$KEYDIR/certs/${CERTNAME}.chain" ]; then
   CHAIN="$KEYDIR/certs/${CERTNAME}.chain"
elif [ -f "$KEYDIR/certs/${CERTNAME}-chain.crt" ]; then
   CHAIN="$KEYDIR/certs/${CERTNAME}-chain.crt"
elif [ -f "$KEYDIR/certs/${CERTNAME}.chain.crt" ]; then
   CHAIN="$KEYDIR/certs/${CERTNAME}.chain.crt"
fi

OPENSSL_ARGS=""
if [ "x$CHAIN" != "x" ]; then
   OPENSSL_ARGS="-chain $CHAIN"
fi

openssl pkcs12 -export -legacy -password "pass:dummy23WhatNot" -out /tmp/${CERTNAME}.p12 -inkey $KEYDIR/private/${CERTNAME}.key -in $KEYDIR/certs/${CERTNAME}.crt $OPENSSL_ARGS

export SERVER_SSL_KEY_STORE=/tmp/${CERTNAME}.p12

exec java $JAVA_OPTS -Dserver.ssl.key-store=$SERVER_SSL_KEY_STORE -Dserver.ssl.key-store-type=PKCS12 -Dserver.ssl.key-store-password=dummy23WhatNot -Dserver.ssl.key-password=dummy23WhatNot -Djava.security.egd=file:/cfg/./urandom -jar /app.jar
