
""" Generates the CollectD JMX configuration for Storm worker nodes
    based off of values pulled from a local Ambari instance"""
import urllib2
import os
import json
from string import Template
from optparse import OptionParser

CONFIG_API = "/api/v1/cluster/configuration"
JSON_HEADER = {"Content-Type": "application/json"}

CONNECTION_TEMPLATE = Template("""
<Connection>
  Host "$host_name"
  ServiceURL "service:jmx:rmi:///jndi/rmi://$service_host/jmxrmi"
  InstancePrefix "$instance"
  Collect "memory-heap"
</Connection>
""")


def get_topology_configuration(config_host):
    request = urllib2.Request(config_host + CONFIG_API)
    for key, val in JSON_HEADER.items():
        request.add_header(key, val)

    response = urllib2.urlopen(request)
    return json.load(response)


def get_supervisor_slots(configuration):
    return configuration['supervisor.slots.ports']


def create_connection_block(slot):
    return CONNECTION_TEMPLATE.substitute(host_name='localhost-{}'.format(slot),
                                          service_host='localhost:{}'.format(
                                              slot),
                                          instance='worker-{}'.format(slot))


def get_worker_jmx_template(path_string):
    template_text = open(os.path.join("templates", "worker_jmx.conf"))
    return Template(template_text.read())


def generate_worker_config():
    parser = OptionParser()
    parser.add_option("-u", "--url", dest="host", default='http://localhost:8744',
                      help="Ambari server host. e.g. http://localhost:8744")

    parser.add_option("-t", "--template", dest="template", default="templates/worker_jmx.conf",
                      help="Template file location")

    parser.add_option("-o", "--output", dest="output",
                      default="worker/collectd_oms_worker_jmx.conf", help="Output File")

    (options, _) = parser.parse_args()
    config_host = options.host

    configuration = get_topology_configuration(config_host)
    slots = get_supervisor_slots(configuration)
    worker_connections = ""
    for slot in slots:
        worker_connections += create_connection_block(slot)

    print 'Created worker blocks for slots {}'.format(slots)

    jmx_template = get_worker_jmx_template(options.template)
    open(options.output, 'w').write(jmx_template.substitute(
        worker_connections=worker_connections))


generate_worker_config()
