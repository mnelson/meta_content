require 'rails/generators/active_record'

class MetaContentGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)

  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end

  def create_migration_file
    migration_template 'migration.rb.erb', "db/migrate/create_#{name}_meta.rb"
  end
end