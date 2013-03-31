require 'active_model'

class MetaObject
  include ActiveModel::Dirty
  extend ActiveModel::Callbacks

  define_model_callbacks :save

  include MetaContent

  def save
    run_callbacks :save do
      true
    end
  end

  def new_record?
    true
  end
end