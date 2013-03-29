module MetaContent
  class Proxy

    class_attribute :meta_methods

    class << self

      def _meta_scope
        namespaces = self.name.split('::')
        namespaces.map do |namespace|
          namespace =~ /DynamicMetaProxy(.+)/
          $1.try(:underscore)
        end.compact.join('__')
      end
    end

    def initialize(record)
      @record = record
    end

    def meta
      meths = self.class.meta_methods
      Hash[meths.map{|meth| [meth, send(meth)]}]
    end

    def inspect
      "<#{self.class.name} #{self.meta.inspect}>"
    end

    protected

    def _meta_object
      @record
    end

  end
end