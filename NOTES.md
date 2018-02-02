#  Cass

## Notes

### installation SSL
Dans le conteneur **cassandra**
    cd /etc/ssl
    keytool -genkey -keyalg RSA -alias node0 -validity 36500 -keystore truststore.node0 -storepass cassandra -keypass cassandra -dname "CN=172.17.0.2, OU=None, O=None, L=None, C=None"
    keytool -certreq -keyalg RSA -alias node0 -file node0.csr -keystore truststore.node0
    openssl req -in node0.csr -noout -text
