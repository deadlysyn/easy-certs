# Make certs, easily.

`mkcert.sh` is a script and opinionated configuration to make generating self-signed certificates easier in development and test environments. __This is not intended for use in production!__ A number of development-specific trade-offs have been made including loose policy defaults, relaxed encryption, non-sensical names, etc.

Often when building or testing something requiring TLS I would resort to Googling the openssl commands. This is a wrapper intended to simplify the number of commands required to spin up an internal CA and generate self-signed certs. Server and user certificates are supported, and you can generate multiple certs at once. The generated CA cert can be imported into browsers or test clients as needed to avoid pop-ups or validation errors.

```bash
❯ ./mkcert.sh
mkcert.sh [server|user] name...
```

Additional prompts will be presented on first run to configure the CA. Customize as needed, or just hit enter to accept the defaults. The usual prompts will then be presented for cert generation. You can again accept defaults for most, paying attention to CN. You can then run again with new names to re-use the CA (or start fresh with a simple `rm -rf certs`).

Example full run to create a server certificate:

```bash
❯ ./mkcert.sh server localhost

******** CERTIFICATE AUTHORITY CONFIGURATION

Generating RSA private key, 4096 bit long modulus
................................................................................................................................................................................................................................................................................................................................++
....................................................................................................................................................++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [US]:
State or Province Name [California]:
Locality Name [Silicon Valley]:
Organization Name [ACME Ltd]:
Organizational Unit Name [ACME Ltd Certificate Authority]:
Common Name []:
Email Address [noreply@acme-ltd.local]:

******** CONFIGURATION FOR localhost

Generating RSA private key, 2048 bit long modulus
..........................+++
...................................................+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [US]:
State or Province Name [California]:
Locality Name [Silicon Valley]:
Organization Name [ACME Ltd]:
Organizational Unit Name [ACME Ltd Certificate Authority]:
Common Name []:localhost <--- THE ONLY THING YOU NEED TO ENTER
Email Address [noreply@acme-ltd.local]:
Using configuration from openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 4096 (0x1000)
        Validity
            Not Before: Nov 21 03:16:43 2019 GMT
            Not After : Nov 30 03:16:43 2020 GMT
        Subject:
            countryName               = US
            stateOrProvinceName       = California
            localityName              = Silicon Valley
            organizationName          = ACME Ltd
            organizationalUnitName    = ACME Ltd Certificate Authority
            commonName                = localhost
            emailAddress              = noreply@acme-ltd.local
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Cert Type:
                SSL Server
            Netscape Comment:
                OpenSSL Generated Server Certificate
            X509v3 Subject Key Identifier:
                F7:F2:56:10:86:82:6C:29:AF:A7:2B:99:00:AD:54:FD:EF:D8:E1:A0
            X509v3 Authority Key Identifier:
                keyid:75:81:0C:2D:EA:B3:AE:81:73:CD:18:63:48:7E:44:59:32:C3:7A:0B
                DirName:/C=US/ST=California/L=Silicon Valley/O=ACME Ltd/OU=ACME Ltd Certificate Authority/emailAddress=noreply@acme-ltd.local
                serial:C1:69:2E:1F:26:66:9D:89

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
Certificate is to be certified until Nov 30 03:16:43 2020 GMT (375 days)

Write out database with 1 new entries
Data Base Updated
```

All output is stored in the generated `certs` directory:

```bash
❯ ls certs
ca.cert        ca.key         db.txt         db.txt.attr    db.txt.old     index.txt      localhost.cert localhost.csr  localhost.key  serial         serial.old
```

# Validating Certs

To quickly validate generated certs, use:

```bash
❯ openssl x509 -noout -text -in certs/localhost.cert
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 4096 (0x1000)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=California, L=Silicon Valley, O=ACME Ltd, OU=ACME Ltd Certificate Authority/emailAddress=noreply@acme-ltd.local
        Validity
            Not Before: Nov 21 03:16:43 2019 GMT
            Not After : Nov 30 03:16:43 2020 GMT
        Subject: C=US, ST=California, L=Silicon Valley, O=ACME Ltd, OU=ACME Ltd Certificate Authority, CN=localhost/emailAddress=noreply@acme-ltd.local
...
```

# Thoughts

Every time I find new ways to use a `Makefile` I'm reminded oldies are often still goodies... For a much more detailed overview of creating a production-ready internal CA, [be sure to check out this guide](https://jamielinux.com/docs/openssl-certificate-authority) from ~2013-2015. :-)

For test environments, you could get a lot simpler than this... Perhaps using a simple command such as `openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 375`. I wanted a consistent wrapper to support server and client certificates, creating multiple certs, etc. It might be overkill for your use case.

SANs are common, but not supported here. For an extremely detailed overview of how to use alternate names, [see the second answer in this Stack Overflow thread](https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl).

