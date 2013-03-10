require "meta_content/version"

module MetaContent
  extend ActiveSupport::Concern

  autoload :Query, 'meta_content/query'
  autoload :Sanitizer, 'meta_content/sanitizer'

  included do
    class_attribute :meta_content_fields
    self.meta_content_fields = HashWithIndifferentAccess.new

    after_save :store_meta
  end

  module ClassMethods

    def meta(*fields)
      options = fields.extract_options!
      fields.each do |field|
        create_accessors_for_meta_field(field, options)
      end
    end

    protected

    def create_accessors_for_meta_field(field, options = {})
      self.meta_content_fields[field] = options

      class_eval <<-EV, __FILE__, __LINE__+1
        def #{field}
          read_meta(:#{field})
        end

        def #{field}=(val)
          write_meta(:#{field}, val)
        end
      EV
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
    meta_query.update_all(updates) if updates.any?
    meta_query.delete_all(deletes) if deletes.any?
  end

  def meta_query
    @meta_query ||= ::MetaContent::Query.new(self)
  end

  def meta_sanitizer
    @meta_sanitizer ||= ::MetaContent::Sanitizer.new(self)
  end

  def meta_changes
    was     = self.send(:attribute_was, :meta) || {}
    is      = self.meta
    updates = {}
    
    is.each do |k,v|
      updates[k] = v if was[k] != v
    end

    deletes = was.keys - is.keys

    [updates, deletes]
  end

  def default_meta(field)
    options = self.class.meta_content_fields[field]
    options.try(:[], :default)
  end

  def read_meta(field)
    self.meta.fetch(field, default_meta(field))
  end

  def write_meta(field, value)
    unless self.meta[field] == value
      attribute_will_change!(field)
      attribute_will_change!(:meta)

      if value.nil?
        self.meta.delete(field)
      else
        self.meta[field] = value
      end
    end
  end


end
