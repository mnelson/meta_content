module MetaContent
  class Dsl

    def initialize(klass, scope)
      @klass = klass
      @scope = scope
    end

    %w(integer int float number date datetime time boolean bool symbol sym string).each do |type|
      class_eval <<-CODE
        def #{type}(*fields)
          options = fields.extract_options!
          options[:type] = :#{type}
          fields.each do |f|
            field(f, options)
          end
        end
      CODE
    end

    def field(*fields)
      options = fields.extract_options!
      options[:scope] = @scope
      fields.each do |field|
        create_accessors_for_meta_field(field, options)
      end
    end

    protected

    def create_accessors_for_meta_field(field, options = {})
      given_scope = options[:scope]
      implied_scope = given_scope || :class

      @klass.meta_content_fields[implied_scope] ||= {}
      @klass.meta_content_fields[implied_scope][field] = options.except(:scope)

      method_name = [given_scope, field].compact.join('_')

      @klass.class_eval <<-EV, __FILE__, __LINE__+1
        def #{field}
          read_meta(:#{implied_scope}, :#{field})
        end

        def #{field}=(val)
          write_meta(:#{implied_scope}, :#{field}, val)
        end
      EV
    end

  end
end