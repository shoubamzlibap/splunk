# Search Head installation
I have installed the search head (and the indexers) with the script [install_splunk.sh](./install_splunk.sh).
It untars the splunk tarball, moves it to the right location (`/opt/splunk`), accepts the license and enables
start at boot.

If desired, a non-default hostname can be set in `etc/system/local/server.conf` with the following parameter:
```
[general]
serverName = theSearchHead
```

## Open Firewall port
If you have a firewall running (true in CentOS 7 by default), open up a port for the http interface (or https, if you have it configured):
```
# web interface
firewall-cmd --add-port=8000/tcp
firewall-cmd --add-port=8000/tcp --permanent
# splunkd, needed for forwarder management
firewall-cmd --add-port=8089/tcp
firewall-cmd --add-port=8089/tcp --permanent
```

## Disable indexing

Disable indexing on the search head, as described in the [splunk docs](http://docs.splunk.com/Documentation/Splunk/7.0.2/DistSearch/Forwardsearchh
eaddata):

Create the file `/opt/splunk/etc/system/local/outputs.conf`:

```
# Turn off indexing on the search head
[indexAndForward]
index = false
 
[tcpout]
defaultGroup = my_search_peers 
forwardedindex.filter.disable = true  
indexAndForward = false 
 
[tcpout:my_search_peers]
server=10.23.23.5:9997,10.23.23.6:9997
```

## Minimum Free diskspace - just for test setups:
This is a setting that will probably not bug you in production, but my test boxes are rather small, with a root fs of just 8GB. Soon your splunk box will complain.

My "solution" is to change the `minFreeSpace` value in `etc/system/local/server.conf` to something below 5GB. I currently do not know, but there is probablyl a reason for this limit, so bevor 
you do this on production I highly recommend you really know what you do. After all, what is 5GB in production? For my laptop's ssd its a bunch, so I am setting this:

```
[diskUsage]
minFreeSpace = 1000
```

## Search peers
Configure the search peers like this:
```
mkdir -p etc/apps/ia_searchpeers/default
cat >>etc/apps/ia_searchpeers/default/distsearch.conf<<EOF
[distributedSearch]
servers = https://10.23.23.5:8089,https://10.23.23.6:8089
EOF
```

## Distribute the key files
This section is copied verbatim from the [splunk docs](http://docs.splunk.com/Documentation/Splunk/7.0.2/DistSearch/Configuredistributedsearch)

If you add search peers via Splunk Web or the CLI, Splunk Enterprise automatically configures authentication. However, if you add peers by editing `distsearch.conf`, you must distribute the key files manually. After adding the search peers and restarting the search head, as described above:

Copy the file `$SPLUNK_HOME/etc/auth/distServerKeys/trusted.pem` from the search head to `$SPLUNK_HOME/etc/auth/distServerKeys/<searchhead_name>/trusted.pem` on each search peer.

The `<searchhead_name>` is the search head's serverName, specified in `server.conf`.

Restart each search peer. 

