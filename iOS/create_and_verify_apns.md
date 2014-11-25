An easy way to generate the cert/keypair [can be found here](http://code.google.com/p/apns-php/wiki/CertificateCreation#Generate_a_Push_Certificate)

Verify your cert was created correctly by running this command (replace with your key/cert name):
```bash
# For Development Certs
openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert server_certificates_bundle_sandbox.pem -key server_certificates_bundle_sandbox.pem

# For Production Certs
openssl s_client -connect gateway.push.apple.com:2195 -cert server_certificates_bundle_sandbox.pem -key server_certificates_bundle_sandbox.pem
````
