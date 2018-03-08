# Search Head

Here I describe the setup of the searchhead.

## Disable indexing

Disable indexing on the search head, as described in the [splunk docs](http://docs.splunk.com/Documentation/Splunk/7.0.2/DistSearch/Forwardsearchheaddata):

Create a local version of your `outputs.conf`:
```
cd /opt/splunk/etc/system`
```
Then edit `local/outputs.conf`:

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

## Configure search peers
Indexers are called "search peers", as they do the actual searching for the search head. 
Search peers are added to the search head by editing or creating 
`$SPLUN_HOME/etc/system/local/distsearch.conf`:
```
[distributedSearch]
servers = https://10.23.23.5:8089,https://10.23.23.6:8089
```

## Distribute the key files
This section is copied verbatim from the [splunk docs](http://docs.splunk.com/Documentation/Splunk/7.0.2/DistSearch/Configuredistributedsearch)

If you add search peers via Splunk Web or the CLI, Splunk Enterprise automatically configures authentication. However, if you add peers by editing `distsearch.conf`, you must distribute the key files manually. After adding the search peers and restarting the search head, as described above:

Copy the file `$SPLUNK_HOME/etc/auth/distServerKeys/trusted.pem` from the search head to `$SPLUNK_HOME/etc/auth/distServerKeys/<searchhead_name>/trusted.pem` on each search peer.

The `<searchhead_name>` is the search head's serverName, specified in `server.conf`.

Restart each search peer. 

