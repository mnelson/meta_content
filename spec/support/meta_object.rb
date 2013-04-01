require 'active_model'

class MetaObject
  include ActiveModel::Dirty
  extend ActiveModel::Callbacks

  define_model_callbacks :save

  include MetaContent

  meta :scope1 do
    string  :test_string
    int     :test_int
    range   :test_range
    float   :test_float
    time    :test_time
    date    :test_date

    meta :subscope1 do
      string :test_string
    end
  end

  meta do
    string  :test_string
    int     :test_int
    range   :test_range
    float   :test_float
    time    :test_time
    date    :test_date
  end

  def save
    run_callbacks :save do
      true
    end
  end

  def new_record?
    true
  end
end