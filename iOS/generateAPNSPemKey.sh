openssl pkcs12 -in pnpush_key.p12 -out pnpush_key.pem -nocerts -nodes
openssl x509 -in pnpush_cert.cer -inform der -out pnpush_cert.pem
cat pnpush_cert.pem pnpush_key.pem > pnpush.pem
