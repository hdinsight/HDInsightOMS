
require 'fluent/filter'

module Fluent
  # This filter takes the the top level JSON object returned by the Storm input
  # plugin and flattens it by creating additional records per collection type.
  # For example, a single record with two sub items becomes three records.
  # Important top-level metadata about the object, such as the topology, is
  # retained in the newly created records as well.
  class StormFlattenFilter < Filter
    Fluent::Plugin.register_filter('filter_storm_flatten', self)

    KEYS_BOLT = %w[emitted errorTime tasks errorHost failed boltId executors
                   processLatency executeLatency transferred errorPort
                   errorLapsedSecs acked encodedBoltId lastError executed
                   capacity errorWorkerLogLink].freeze

    KEYS_SPOUT = %w[emitted spoutId errorTime tasks errorHost failed
                    completeLatency executors encodedSpoutId
                    transferred errorPort errorLapsedSecs acked
                    errorWorkerLogLink].freeze

    KEYS_TOPOLOGY = %w[window windowPretty emitted transferred acked failed
                       completeLatency].freeze

    PREFIX_TOPOLOGY_STATS = 'topologyStats'.freeze
    PREFIX_SPOUTS = 'spouts'.freeze
    PREFIX_BOLTS = 'bolts'.freeze

    ID_TOPOLOGY_STATS = 'window'.freeze
    ID_BOLTS = 'boltId'.freeze
    ID_SPOUTS = 'spoutId'.freeze

    def initialize
      super
      require_relative 'omslog'
      require_relative 'oms_common'
    end

    def configure(conf)
      super
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter_stream(tag, es)
      ns = MultiEventStream.new
      es.each do |time, record|
        new_records = split_record(record)
        new_records.each do |new_record|
          filtered = filter(tag, time, new_record)
          @log.debug("Outputting new record: #{filtered}\n\n")
          ns.add(time, filtered) if filtered
        end
      end
      ns
    end

    def split_record(record)
      n_records = [record]
      n_records.concat split_prefix(record, PREFIX_BOLTS, ID_BOLTS, 'bolt', KEYS_BOLT)
      n_records.concat split_prefix(record, PREFIX_SPOUTS, ID_SPOUTS, 'spout', KEYS_SPOUT)
      n_records.concat split_prefix(record, PREFIX_TOPOLOGY_STATS, ID_TOPOLOGY_STATS, 'topology_stats', KEYS_TOPOLOGY)
      add_metadata(record, record['name'], record['encodedId'], 'topology')
      record.delete(PREFIX_BOLTS)
      record.delete(PREFIX_SPOUTS)
      record.delete(PREFIX_TOPOLOGY_STATS)
      n_records
    end

    def split_prefix(record, prefix, id_field, instance, keys)
      new_records = []
      record[prefix].each do |item|
        new_item = copy_new(item, keys)
        add_metadata(new_item, item[id_field], record['encodedId'], instance)
        new_records << new_item
      end
      new_records
    end

    def add_metadata(record, id, topology_id, instance_name)
      record['id'] = id.to_s
      record['topologyId'] = topology_id
      record['InstanceName'] = instance_name
    end

    def copy_val(src, dest, key)
      val = src[key]
      val = val.to_f if number?(val)
      dest[key] = val
    end

    def copy_new(src, keys)
      dest = {}
      keys.each do |key|
        copy_val(src, dest, key)
      end
      dest
    end

    def filter(_tag, _time, record)
      record
    end

    def number?(string)
      true if Float(string)
    rescue
      false
    end
  end
end
