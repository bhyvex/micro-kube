#!/bin/bash -e

# define location of openssl binary manually since running this
# script under Vagrant fails on some systems without it
OPENSSL=/usr/bin/openssl

function usage {
    echo "USAGE: $0 <output-dir> [SAN,SAN,SAN]"
    echo "  example: $0 ./ssl IP.1=10.3.0.1,IP.2=172.17.8.100"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

if [ ! -d $1 ]; then
    echo "ERROR: output directory does not exist: $1"
    exit 1
fi

OUTDIR=$1
SANS=$2

OUTFILE="$OUTDIR/ssl.tar"

CNF_TEMPLATE="
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
"

echo "Generating SSL artifacts in: $OUTDIR"

# Add SANs to openssl config
echo "$CNF_TEMPLATE$(echo $SANS | tr ',' '\n')" > $OUTDIR/apiserver-req.cnf

# establish cluster CA and self-sign a cert
$OPENSSL genrsa -out $OUTDIR/ca-key.pem 2048
$OPENSSL req -x509 -new -nodes -key $OUTDIR/ca-key.pem -days 10000 -out $OUTDIR/ca.pem -subj "/CN=kube-ca"

# create apiserver key and signed cert
$OPENSSL genrsa -out $OUTDIR/apiserver-key.pem 2048
$OPENSSL req -new -key $OUTDIR/apiserver-key.pem -out $OUTDIR/apiserver.csr -subj "/CN=kube-apiserver" -config $OUTDIR/apiserver-req.cnf
$OPENSSL x509 -req -in $OUTDIR/apiserver.csr -CA $OUTDIR/ca.pem -CAkey $OUTDIR/ca-key.pem -CAcreateserial -out $OUTDIR/apiserver.pem -days 10000 -extensions v3_req -extfile $OUTDIR/apiserver-req.cnf

# create admin key and signed cert
$OPENSSL genrsa -out $OUTDIR/admin-key.pem 2048
$OPENSSL req -new -key $OUTDIR/admin-key.pem -out $OUTDIR/admin.csr -subj "/CN=kube-admin"
$OPENSSL x509 -req -in $OUTDIR/admin.csr -CA $OUTDIR/ca.pem -CAkey $OUTDIR/ca-key.pem -CAcreateserial -out $OUTDIR/admin.pem -days 10000

tar -cf $OUTFILE -C $OUTDIR/ ca.pem apiserver.pem apiserver-key.pem

echo "Bundled SSL artifacts into $OUTFILE"
