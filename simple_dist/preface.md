## Preface

These are notes I took while learning how to deploy splunk.

### My boxes
To actually try out things I had four virtual boxes with centos 7.4 installed: 
```
          searchhead
          10.23.23.4
          /         \
          |         |
       idx1         idx2
    10.23.23.5   10.23.23.6
          \       /
           \     /
           datamill
          10.23.23.7
```


The current splunk version as of this writing is 7.0.2, but things should also work with older and newer versions.
