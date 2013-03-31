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
      when :integer, :fixnum
        value.to_i
      when :float, :number
        value.to_f
      when :date
        Time.zone.at(value.to_i).to_date
      when :datetime, :time
        Time.zone.at(value.to_i)
      when :boolean, :bool
        !!(value.to_s =~ /1|t|y/)
      when :symbol, :sym
        value.to_sym
      when :array, :arr, :hash, :json
        JSON.parse(value.to_s)
      when :enum, :enumerator
        arr = JSON.parse(value.to_s)
        Enumerator.new(arr)
      else
        value
      end
    end

    def sanitize_in(value, type)
      case type
      when :date, :datetime, :time
        value.to_time.to_i
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