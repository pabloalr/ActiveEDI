module ActiveEDI
  module Attributes #:nodoc:

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def define_methods
        schema.each_key do |attr|
          create_read_method(attr)
          create_write_method(attr)
          create_writer_method_for_parser(attr)
          create_reader_method_to_persist(attr)
        end
      end

      # Return the attribute hash of specified element
      def attributes_hash(element)
        schema[element.to_sym]
      end

      def attribute_type(element)
        attributes_hash(element)[:type]
      end

      def attribute_decimal(element)
        attributes_hash(element)[:decimal] || nil
      end

      def attribute_size(element)
        size = attributes_hash(element)[:size]
        decimal = attribute_decimal(element)
        if decimal
          size += decimal
        end
        size
      end

      def attribute_pos(element)
        attributes_hash(element)[:pos]
      end

      private
        def create_read_method(attr_name)
          class_eval "def #{attr_name}; read_attribute('#{attr_name.to_sym}'); end", __FILE__, __LINE__
        end

        def create_write_method(attr_name)
          class_eval "def #{attr_name}=(new_value);write_attribute('#{attr_name.to_sym}', new_value);end", __FILE__, __LINE__
        end

        def create_writer_method_for_parser(attr_name)
          class_eval "def #{attr_name}_parser=(new_value);write_parsed_attribute('#{attr_name.to_sym}', new_value);end", __FILE__, __LINE__
        end

        def create_reader_method_to_persist(attr_name)
          class_eval "def persist_#{attr_name}; read_attribute_to_persist('#{attr_name.to_sym}'); end", __FILE__, __LINE__
        end

    end

    def read_attribute(attr)
      read_handle_attribute(attr.to_sym)
    end

    # The class receive the value as a normal Ruby data and convert it to a string according to defined data type
    def write_attribute(attr, value)
      write_handle_attribute(attr, value)
    end

    # Get a string and set this class attribute as data type
    def write_parsed_attribute(attr, value)
      write_handler_for_parsed_attribute(attr, value)
    end

    # Retrieve an attribute from @attributes and show as text to persist the data
    def read_attribute_to_persist(attr)
      read_handler_for_persistence(attr.to_sym)
    end

    private

      # Detects if this attribute is of type number or string and throw the right handler
      def read_handle_attribute(attribute)
        @attributes[attribute.to_s]
      end

      def write_handle_attribute(attr, val)
        case self.class.attribute_type(attr)
          when :string then
            @attributes[attr] = val.to_s.gsub(/[.,]/, "")
          when :numeric then
            @attributes[attr] = self.class.attribute_decimal(attr).nil? ? val : val.to_f
          else
            @attributes[attr] = val
        end
      end

      # Convert a text from input to a Ruby object and store on attribute's hash
      def write_handler_for_parsed_attribute(attr, val)
        case self.class.attribute_type(attr)
          when :string then
            @attributes[attr] = val.to_s.gsub(/[,.]/, "").squeeze.gsub(/(.+) $/, '\1')
          when :numeric then
            decimal = self.class.attribute_decimal(attr)
            if decimal
              dot = val.length - decimal
              @attributes[attr] = "#{val[0, dot]}.#{val[dot, val.length]}".to_f
            else
              @attributes[attr] = val.to_i
            end
          when :date then
            @attributes[attr] = Date.strptime(val, ActiveEDI::DEFAULT_DATE_MASK)
        end
      end

      def read_handler_for_persistence(attr)
        attr_name = attr.to_s
        case self.class.attribute_type(attr)
          when :string then
            # Formats attribute output as string, ajusting text to the left and filling remaining with spaces
            @attributes[attr_name].to_s.ljust(self.class.attribute_size(attr), " ")
          when :numeric then
            # Formats attribute output as number, aligns to the right and fill remaining spaces with zero
            val = @attributes[attr_name].to_s
            if self.class.attribute_decimal(attr)
              match = val.match(/(\d*)\.?(\d*)/)
              # Wodoo to make sure we have at least 2 digits after "."
              decimal = match[2].size < 2 ? "00" : match[2]
              val = "#{match[1]}#{decimal}"
            end
            val.rjust(self.class.attribute_size(attr), "0")
          when :date then
            @attributes[attr_name].strftime(ActiveEDI::DEFAULT_DATE_MASK)
        end
      end
  end
end
