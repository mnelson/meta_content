require "meta_content/version"

module MetaContent
  extend ActiveSupport::Concern

  autoload :Dsl,        'meta_content/dsl'
  autoload :Query,      'meta_content/query'
  autoload :Sanitizer,  'meta_content/sanitizer'

  included do
    class_attribute :meta_content_fields
    self.meta_content_fields = HashWithIndifferentAccess.new

    after_save :store_meta
  end

  module ClassMethods

    def meta(scope = nil, &block)
      dsl = MetaContent::Dsl.new(self, scope)
      dsl.instance_eval(&block)
    end

  end

  def reload(*args)
    @meta = nil
    super
  end

  def meta
    @meta ||= retrieve_meta
  end


  protected

  def retrieve_meta
    return @meta unless @meta.nil?
    return {} if new_record?

    meta_sanitizer.sanitize(meta_query.select_all)
  end

  def store_meta
    updates, deletes = meta_changes
    meta_query.update_all(updates)
    meta_query.delete_all(deletes)
  end

  def meta_query
    @meta_query ||= ::MetaContent::Query.new(self)
  end

  def meta_sanitizer
    @meta_sanitizer ||= ::MetaContent::Sanitizer.new(self)
  end

  def meta_changes
    return [{}, {}] if @meta.nil?

    was     = self.send(:attribute_was, :meta) || {}
    is      = self.meta

    updates = {}
    deletes = {}

    is.each do |scope,scoped_is|
      scoped_was = was[scope] || {}
      scoped_is.each do |k,v|
        updates[scope] ||= {}
        updates[scope][k] = v if was[k] != v
      end

      deletes[scope] = scoped_was.keys - scoped_is.keys
    end

    [updates, deletes]
  end

  def default_meta(scope, field)
    options = self.class.meta_content_fields.fetch(scope, {})
    options.fetch(:default, nil)
  end

  def read_meta(scope, field)
    scoped_meta = self.meta.fetch(scope, {})
    scoped_meta.fetch(field, default_meta(scope, field))
  end

  def write_meta(scope, field, value)
    self.meta[scope] ||= {}
    unless self.meta[scope][field] == value
      attribute_name = scope.to_s == 'class' ? field : [scope, field].join('_')
      attribute_will_change!(attribute_name)
      attribute_will_change!(:meta)

      if value.nil?
        self.meta[scope].delete(field)
      else
        self.meta[scope][field] = value
      end
    end
  end


end
