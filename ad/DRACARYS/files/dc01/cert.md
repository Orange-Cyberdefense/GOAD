openssl genrsa -out ldaps.key 2048
openssl req -new -x509 -key ldaps.key -out ldaps.crt -days 3650 -subj "/CN=balerion.dracarys.lab" -addext "subjectAltName = DNS:balerion.dracarys.lab,DNS:balerion"
openssl pkcs12 -export -out ldaps.pfx -inkey ldaps.key -in ldaps.crt -passout pass:MyStr@ngeCertP@ssword123
