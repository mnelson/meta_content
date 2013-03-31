require "meta_content/version"

module MetaContent

  autoload :Dsl,        'meta_content/dsl'
  autoload :Proxy,      'meta_content/proxy'
  autoload :Query,      'meta_content/query'
  autoload :Sanitizer,  'meta_content/sanitizer'

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      after_save :_store_meta
    end
  end

  module ClassMethods

    def meta(scope = nil, &block)
      MetaContent::Dsl.meta(self, scope, &block)
    end

    def _meta_scope
      ''
    end

  end

  def reload(*args)
    @meta = nil
    super
  end

  def meta
    @meta ||= _retrieve_meta
  end

  def apply_meta(scope, data)
    data.each do |k,v|
      self._write_meta(scope, k, v)
    end
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s =~ /^([a-z0-9]+)__/
      
      scope_methods = method_name.to_s.split('__')
      
      object = self
      while scope_methods.length > 1
        object = object.send(scope_methods.shift)
      end

      object.send(scope_methods.first, *args)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    super || method_name.to_s =~ /^([a-z0-9]+)__/
  end


  protected

  def _meta_object
    self
  end

  def _retrieve_meta
    return {} if new_record?

    _meta_sanitizer.sanitize_all_out(_meta_query.select_all)
  end

  def _store_meta
    updates, deletes  = _meta_changes
    updates           = _meta_sanitizer.sanitize_all_in(updates)
    
    _meta_query.update_all(updates)
    _meta_query.delete_all(deletes)
  end

  def _meta_query
    @meta_query ||= ::MetaContent::Query.new(self)
  end

  def _meta_sanitizer
    @meta_sanitizer ||= ::MetaContent::Sanitizer.new(self)
  end

  def _meta_changes
    return [{}, []] if @meta.nil?

    was     = self.send(:attribute_was, :meta) || {}
    is      = self.meta

    updates = {}
    deletes = []

    deletes = was.keys - is.keys
    is.each do |k,v|
      if v.nil?
        deletes << k
      elsif was[k] != v
        updates[k] = v 
      end
    end

    [updates, deletes]
  end

  def _read_meta(scope, field)
    key = [scope, field].flatten.reject(&:blank?).join('__')
    self.meta[key]
  end

  def _write_meta(scope, field, value)
    key = [scope, field].flatten.reject(&:blank?).join('__')
    
    unless self.meta[key] == value
      send(:attribute_will_change!, :meta)
      if value.nil?
        self.meta.delete(key)
      else
        self.meta[key] = value
      end
    end
  end


end
