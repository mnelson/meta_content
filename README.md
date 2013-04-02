# MetaContent

Fast and queryable schemaless MySQL. MetaContent stores attributes of your model across multiple rows in a separate table. It allows you to treat attributes as ancillary data rather than incurring the load of initializing or storing them upon update.

## Installation

Add to your Gemfile

```
gem 'meta_content'
```

## Data

Create a table for your class

```
rails g meta_content [your_class_name]
rails g meta_content user
```
This will create a table named [your_class_name]_meta. This table will hold the meta attributes for the class as soon as you include the `MetaContent` module into it.

## Usage

Include the `MetaContent` module into your class.

```
class User < ActiveRecord::Base
  include MetaContent
  # ...
end	
```

Then describe the attributes using meta blocks:

```
class User < ActiveRecord::Base

  meta do
    string :my_field
  end
	
  meta :scoped_meta do
    integer :visitor_count
    string  :visit_path
    
    meta :subscoped_meta do
      range :visitor_ages
    end
  end

end
```

Now you can access these attributes in the following way:

```
u = User.new

u.my_field = 'test'
u.my_field
# => 'test'

u.meta
# => {:my_field => 'test'}

u.scoped_meta
# => <MetaContent::Proxy …>

u.scoped_meta.visitor_count = 30
u.scoped_meta.visitor_count
# => 30

u.scoped_meta__visitor_count
# => 30
u.scoped_meta.meta
# => {:visitor_count => 30}

u.scoped_meta = {:visitor_count => 3, :visit_path => '/test'}
u.scoped_meta__visitor_count
# => 3

u.scoped_meta__subscoped_meta__visitor_ages = (30..40)
u.scoped_meta__subscoped_meta__visitor_ages
# => (30..40)
u.scoped_meta.subscoped_meta.visitor_ages
# => (30..40)
```

You'll notice accessors are provided for all meta content, even if it's scoped. You can apply this data just like any other attribute:

```
User.new(:scoped_meta__visitor_count => 3)
```

# Fast, Slow, Huh?

It's fast. It uses MySQL's `ON DUPLICATE KEY UPDATE` syntax to only ever conduct 1 or 2 queries when changes are made. If no changes are made, nothing is written. Unlike serialized content, it will not impact your table's performance.

# Scalability

Not sure what the upper limit of this statement is but up through a few million records in the meta table I've seen no change in query times. I'll try to push this up to a few hundred million records and try again at some point.