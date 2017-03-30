#!/bin/bash
wget https://github.com/Microsoft/OMS-Agent-for-Linux/releases/download/OMSAgent-201702-v1.3.1-15/omsagent-1.3.1-15.universal.x64.sh -O /tmp/omsagent.x64.sh
sudo sh /tmp/omsagent.x64.sh --upgrade
if [[ $HOSTNAME == hn* ]];
then
  sudo wget https://raw.githubusercontent.com/duoxu/hbase-utils/master/monitoring/spark.headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/spark.headnode.conf
  sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/yarn.headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.headnode.conf

else
  sudo wget https://raw.githubusercontent.com/duoxu/hbase-utils/master/monitoring/spark.workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/spark.workernode.conf
  sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/yarn.workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.workernode.conf

fi
wget https://raw.githubusercontent.com/duoxu/hbase-utils/master/monitoring/in_exec.patch
sudo patch -p0 -N /opt/microsoft/omsagent/ruby/lib/ruby/gems/2.3.0/gems/fluentd-0.12.24/lib/fluent/plugin/in_exec.rb < in_exec.patch
sudo sh -x /opt/microsoft/omsagent/bin/omsadmin.sh -w $1 -s $2
sudo /opt/microsoft/omsagent/bin/service_control restart
