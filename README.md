<H1> Install OMS Monitoring in HDInsight cluster </H1> 
 Use following script actions in HDInsight cluster to install OMS integration for following components. Script action needs two parameters from your OMS Log Analytics Workspace
 
 <code>
workspaceid, worspacekey
</code>
 
  
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
Once installed, you can check HDInsight Logs and Metrics data in Azure Log Analytics
