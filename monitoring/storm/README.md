# Apache Storm -> Microsoft OMS

## Setup

1. Run a [Script Action](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-script-actions-linux) using `hdStormOms.sh`
1. Create a new OMS View in the View Designer and import the provided `storm.omsview` to create an example OMS view based on the installed Storm metrics

## Queries to try

Topologies currently running

```
* Type=stormrestmetrics_CL status_s="ACTIVE"  TimeGenerated >NOW-1HOUR | dedup topologyId_s | select topologyId_s
```

Average Capacity by Topology

```
* Type=stormrestmetrics_CL | measure avg(capacity_d) as Capacity by topologyId_s interval 1MINUTE
```