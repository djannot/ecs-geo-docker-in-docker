update-ca-certificates
mkdir /disks
mkdir /files
for i in {1..2}; do
  mkdir /disks/$i
  mkdir /files/$i
  for j in {1..5}; do
    l=`echo $j | tr 12345 bcdef`
    truncate -s 100G /files/$i/$j
    mknod /dev/loop$i$j b 7 $i$j
    chown --reference=/dev/loop0 /dev/loop$i$j
    chmod --reference=/dev/loop0 /dev/loop$i$j
    losetup /dev/loop$i$j /files/$i/$j
    mkfs.xfs -f /dev/loop$i$j
    mkdir /disks/$i/uuid-sd${l}1
    mount /dev/loop$i$j /disks/$i/uuid-sd${l}1
    /additional-prep.sh /dev/loop$i$j
    rm /disks/$i/uuid-sd${l}1/0009
  done
done
chmod -R 777 /disks

docker run -d -e SS_GENCONFIG=1 --name=ecs1 --hostname=ecs1.localdomain -p 443:443 -p 4443:4443 -p 8443:8443 -p 9020:9020 -p 9021:9021 -p 9022:9022 -p 9023:9023 -p 9024:9024 -p 9025:9025 -v /network.json.10.0.0.1:/host/data/network.json -v /seeds1:/host/files/seeds -v /partitions.json:/data/partitions.json -v /disks/1:/disks -v /var/log/ecs/1:/opt/storageos/logs djannot/ecs:v2.0HF2
sleep 5
docker exec -i -t ecs1 chmod -R 777 /host
docker run -d -e SS_GENCONFIG=1 --name=ecs2 --hostname=ecs2.localdomain -p 2443:443 -p 24443:4443 -p 28443:8443 -p 29020:9020 -p 29021:9021 -p 29022:9022 -p 29023:9023 -p 29024:9024 -p 29025:9025 -v /network.json.10.0.0.2:/host/data/network.json -v /seeds2:/host/files/seeds -v /partitions.json:/data/partitions.json -v /disks/2:/disks -v /var/log/ecs/2:/opt/storageos/logs djannot/ecs:v2.0HF2
sleep 5
docker exec -i -t ecs2 chmod -R 777 /host
