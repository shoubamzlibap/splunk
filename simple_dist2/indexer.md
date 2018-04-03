# Indexer Installation

I have installed the indexers with the same minimal script, [install_splunk.sh](./install_splunk.sh).

Again, I have set the servername in `/opt/splunk/etc/system/local/server.conf`:
```
[general]
serverName = myIndexer2
```

## Create indexes
Create some indexes by creating an `indexes.conf` file, preferably inside an app:
```
mkdir -p etc/apps/ia_indexes/default
cat >>etc/apps/ia_indexes/default/indexes.conf<<EOF
[main]
disabled = 0
homePath = $SPLUNK_DB/$_index_name/db
coldPath = $SPLUNK_DB/$_index_name/colddb
thawedPath = /opt/frozen/main
maxTotalDataSizeMB = 1000
maxDataSize = 100

[web]
disabled = 0
homePath = $SPLUNK_DB/$_index_name/db
coldPath = $SPLUNK_DB/$_index_name/colddb
thawedPath = /opt/frozen/web
maxTotalDataSizeMB = 1000
maxDataSize = 100

EOF
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
