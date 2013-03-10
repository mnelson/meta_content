module MetaContent
  class Sanitizer

    def initialize(record)
      @record = record
    end

    def sanitize(raw_results)
      sanitized_results = HashWithIndifferentAccess.new
      raw_results.each do |k,v|
        options = schema[k]
        next unless options
        sanitized_results[k] = sanitize_value(v, options[:type] || :string)
      end
      sanitized_results
    end

    protected

    def sanitize_value(value, type)
      case type
      when :integer, :fixnum
        value.to_i
      when :float, :number
        value.to_f
      when :date
        Date.parse(value)
      when :datetime, :time
        Time.parse(value)
      when :boolean, :bool
        !!(value.to_s =~ /1|t|y/)
      when :symbol, :sym
        value.to_sym
      else
        value
      end
    end

    def klass
      @record.class
    end

    def schema
      klass.meta_content_fields
    end

  end
end