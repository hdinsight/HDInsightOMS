<H1> Install OMS Monitoring in HDInsight clutser </H1> 
 Use folling Script actions in HDInsight cluster to install OMS integration for following components. Script actions needs two parameters from your OMS Log Analytics Workspace
 
 
<workspaceid>,<worspacekey>

 
  
## HBase
Select Head Node, Worker Node & Zookeeper Nodes
  ```shell
  https://raw.githubusercontent.com/hdinsight/HDInsightOMS/master/monitoring/script2.sh
  ```
## Spark
Select Head Node, Worker Nodes

```shell
https://raw.githubusercontent.com/hdinsight/HDInsightOMS/master/monitoring/scriptspark.sh
```
## Interactive Hive
Select Head Node, Worker Nodes
```shell
https://raw.githubusercontent.com/hdinsight/HDInsightOMS/master/monitoring/installintractivehive.sh
```
##  Hive
Select Head Node, Worker Nodes
```shell
https://raw.githubusercontent.com/hdinsight/HDInsightOMS/master/monitoring/hivescript.sh
```

