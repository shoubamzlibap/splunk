# Indexer Installation

I have installed the indexers with the same minimal script, [install_splunk.sh](./install_splunk.sh).

Again, I have set the servername in `/opt/splunk/etc/system/local/server.conf`:
```
[general]
serverName = myIndexer2
```

## Listen for tcp input
Make your indexer listen for tcp input on port 9997. On the indexers, in `etc/system/local/inputs.conf`, add the following two lines:

```
[splunktcp:9997]
disabled = 0 
```

Its better to create a seperate app:
```
mkdir -p etc/apps/ia_indexing/default
cat >>etc/apps/ia_indexing/default/inputs.conf<<EOF
[splunktcp:9997]
disabled = 0
EOF
```

## Open Firewall port
If you have a firewall running (true in CentOS 7 by default), open up the following ports
```
firewall-cmd --add-port=9997/tcp --permanent # indexing port
firewall-cmd --add-port=8089/tcp --permanent # splunkd
firewall-cmd --reload
```

