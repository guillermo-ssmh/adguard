docker run --name adguardhome \
--restart unless-stopped    \
-v /opt/adguard/work:/opt/adguardhome/work    \
-v /opt/adguard/conf:/opt/adguardhome/conf    \
-d \
-p 53:53/tcp -p 53:53/udp    \
-p 67:67/udp -p 68:68/udp    \
-p 80:80/tcp \
-p 443:443/tcp      -p 443:443/udp \
-p 3000:3000/tcp    -p 784:784/udp \
-p 853:853/tcp      -p 853:853/udp \
-p 5443:5443/tcp    -p 5443:5443/udp  \
-p 8853:8853/udp \
--network=host --cap-add=NET_ADMIN --cap-add=NET_RAW \
adguard/adguardhome
