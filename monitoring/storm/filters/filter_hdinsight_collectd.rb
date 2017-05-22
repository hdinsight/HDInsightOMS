
module Fluent
  require_relative 'omslog'
  require_relative 'oms_common'
  require 'json'
  require 'open3'

  # TODO: add better documentation to explain why this filter is necessary
  class HdinsightCollectdFilter < Filter
    Fluent::Plugin.register_filter('filter_hdinsight_collectd', self)

    BASE_DIR = File.dirname(File.expand_path('..', __FILE__))
    RUBY_DIR = BASE_DIR + '/ruby/bin/ruby '

    def configure(conf)
      super
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter(_tag, _time, record)
      dataItems = record['DataItems'][0]
      if dataItems
        unless dataItems['Timestamp'].nil?
          record['Timestamp'] = dataItems['Timestamp']
        end
        unless dataItems['ObjectName'].nil?
          record['ObjectName'] = dataItems['ObjectName']
        end
        unless dataItems['InstanceName'].nil?
          record['InstanceName'] = dataItems['InstanceName']
        end
        unless dataItems['Collections'].nil?
          # # Flatten Name='countername', Value='CounterValue' pairs
          # # Collectd and OMS do not take kindly to . in names, replace with _
          dataItems['Collections'].each do |counters|
            next if counters['CounterName'].nil? || counters['Value'].nil?
            countername = counters['CounterName'].tr('.', '_')
            record[countername] = dataItems['InstanceName']
          end
        end
      end
      # Don't need this no more as all data is flattened into main record..
      record.delete('DataItems')
      record
    end
  end
end