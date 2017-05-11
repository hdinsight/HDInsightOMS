
require 'fluent/filter'

module Fluent
  # Provides additional record information not provided by Storm REST API
  # metrics. In ideal usage, this filter is chained as follows:
  #     in_storm -> filter_storm_flatten -> filter_hdinsight -> filter_storm_oms
  class OmsStormFilter < Filter
    Fluent::Plugin.register_filter('filter_storm_oms', self)

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

    def filter(_tag, time, record)
      @log.debug("Pre filter: #{record}")
      record['Timestamp'] = OMS::Common.format_time(Time.now.to_f)
      record['EventTime'] = OMS::Common.format_time(time)
      @log.debug("Post filter: #{record}")
      record
    end
  end
end