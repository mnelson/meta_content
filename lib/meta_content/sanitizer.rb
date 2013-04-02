require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/object/to_json'
require 'active_support/json'

module MetaContent
  class Sanitizer

    def initialize(record)
      @record = record
    end

    def sanitize_all_out(values)
      out = {}

      values.each do |k,v|
        type = type_from_key(k)
        out[k] = sanitize_out(v, type)
      end

      out
    end

    def sanitize_all_in(values)
      out = {}

      values.each do |k,v|
        type = type_from_key(k)
        out[k] = sanitize_in(v, type)
      end

      out
    end

    protected

    def sanitize_out(value, type)
      case type
      when :integer, :fixnum, :int
        value.to_i
      when :float, :number
        value.to_f
      when :date
        Time.at(value.to_i).to_date
      when :datetime, :time
        Time.at(value.to_i)
      when :boolean, :bool
        !!(value.to_s =~ /1|t|y/)
      when :symbol, :sym
        value.to_sym
      when :array, :arr, :hash, :json
        ActiveSupport::JSON.decode(value.to_s)
      when :range
        arr = ActiveSupport::JSON.decode(value.to_s)
        if arr[2]
          (arr[0]...arr[1])
        else
          (arr[0]..arr[1])
        end
      else
        value
      end
    end

    def sanitize_in(value, type)
      case type
      when :date, :datetime, :time
        value = value.to_time if value.respond_to?(:to_time)
        value.to_i.to_s
      when :boolean, :bool
        value.to_s =~ /1|t|y/ ? '1' : '0'
      when :array, :arr
        Array(value).to_json
      when :enum, :enumerator
        Array(value.entries).to_json
      when :hash
        value.to_json
      when :json
        value.is_a?(String) ? value : value.to_json
      when :range
        [value.first, value.last, value.exclude_end?].to_json
      else
        value.to_s
      end
    end

    def type_from_key(key)
      scopes = key.split('__').reject(&:blank?)
      field  = scopes.pop

      resource = @record
      while scope = scopes.shift
        resource = resource.send(scope)
      end
      
      resource.send("#{field}_type")
    end

  end
end