require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/string/inflections'
module MetaContent
  class Dsl

    FIELD_TYPES = %w(integer int float number date datetime time boolean bool symbol sym string array arr enum enumerator json hash)

    class << self
      def class_for_scope(base_class, scope = nil)
        return base_class if scope.blank?

        class_name = "DynamicMetaProxy#{scope.to_s.classify}"
        
        if base_class.const_defined?(class_name)
          base_class.const_get(class_name) 
        else
          klass = Class.new(MetaContent::Proxy)
          base_class.const_set(class_name, klass)
          base_class.class_eval <<-EV, __FILE__, __LINE__ + 1
            def #{scope}
              #{class_name}.new(self._meta_object)
            end

            def #{scope}=(data)
              proxy = #{class_name}.new(self._meta_object)
              data.each do |k,v|
                proxy.send("\#{k}=", v)
              end
            end
          EV
          klass
        end
      end

      def meta(klass, scope, &block)
        dsl = MetaContent::Dsl.new(klass, scope)
        dsl.instance_eval(&block)
      end

    end

    def initialize(base_class, scope = nil)
      @scope      = scope
      @base_class = base_class
      @klass      = MetaContent::Dsl.class_for_scope(@base_class, @scope)
    end

    def meta(scope, &block)
      MetaContent::Dsl.meta(@klass, scope, &block)
    end

    FIELD_TYPES.each do |type|
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
      fields.each do |field|
        create_accessors_for_meta_field(field, options)
      end
    end

    protected

    def create_accessors_for_meta_field(field, options = {})
      @klass.class_eval <<-EV, __FILE__, __LINE__ + 1
        def #{field}
          self._meta_object.send(:_read_meta, self.class._meta_scope, :#{field})
        end

        def #{field}=(val)
          self._meta_object.send(:_write_meta, self.class._meta_scope, :#{field}, val)
        end
      EV

      options.each do |k,v|
        @klass.class_eval <<-EV, __FILE__, __LINE__ + 1
          def #{field}_#{k}
            #{v.inspect}
          end
        EV
      end

      if @klass.respond_to?(:meta_methods=)
        @klass.meta_methods ||= []
        @klass.meta_methods << field
      end
    end

  end
end