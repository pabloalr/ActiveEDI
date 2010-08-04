module ActiveEDI

  DEFAULT_DATE_MASK = "%d%m%Y"

  class Base #:nodoc:
    attr_accessor :read_charset, :write_charset


    def initialize()
      read_charset ||= "utf-8"
      write_charset ||= "utf-8"
      @attributes = {}
      self.class.define_methods
    end

    def get_ordered_values_to_persist
      result = []
      self.class.ordered_schema.each do |k|
        result << self.send("persist_#{k}")
      end
      result
    end

    # Dump the ActiveEDI object as text, ordering by "pos"
    def to_s
      values = get_ordered_values_to_persist
      values.join("")
    end

    class << self

      def ordered_schema
        schema.sort {|a, b| a[1][:pos] <=> b[1][:pos]}.map {|c| c[0]}
      end

      # Load a text file and create ActiveEDI instances as needed, according to the field set as type found at each line
      def load_data(file_name)
        if File.exists?(file_name) and File.readable?(file_name)
          file = File.new(file_name)
          r = []
          file.readlines.each do |line|
            # TODO
          end
          r
        end
      end

      # Parse a text line to create a new object
      def parse(line)
        obj = self.new
        last_pos = 0
        ordered_schema.each do |attr|
          # here we'r dealing with a string, so we should subtract 1 from size
          size = last_pos + attribute_size(attr)
          obj.send("#{attr}_parser=", line[last_pos..size-1])
          last_pos = size
        end
        obj
      end

    end
  end
end
