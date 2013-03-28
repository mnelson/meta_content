module MetaContent
  class Proxy

    class << self

      def _meta_scope
        namespaces = self.name.split('::')
        namespaces.map do |namespace|
          namespace =~ /DynamicMetaClass(.+)/
          $1.try(:underscore)
        end.compact.join('/')
      end
    end

    def initialize(record)
      @record = record
    end

    def _meta_object
      @record
    end

  end
end