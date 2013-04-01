require 'spec_helper'

describe MetaContent do

  let(:obj){ MetaObject.new }

  it 'provides accessors' do
    obj.test_string = 'test'
    obj.test_string.should eql('test')

    obj.scope1__test_string = 'test'
    obj.scope1__test_string.should eql('test')
  end

  it 'provides scoped accessors' do
    obj.scope1.test_string = 'test'
    obj.scope1.test_string.should eql('test')

    obj.scope1.meta[:test_string].should eql('test')
  end

  it 'allows entire scopes to be set' do
    obj.scope1 = {:test_string => 'test', :test_int => 44, :test_range => (0..10)}
    obj.scope1__test_string.should eql('test')
    obj.scope1__test_int.should eql(44)
    obj.scope1__test_range.should eql((0..10))

    obj.scope1.test_int.should eql(44)
  end

  it 'determines the changes properly' do

    obj.scope1.test_string = 'test'
    obj.test_string = 'hey'

    obj.changes.keys.should include(:meta)
    obj.changes[:meta].should eql([{}, {'scope1__test_string' => 'test', 'test_string' => 'hey'}])

    obj.instance_variable_get('@changed_attributes').clear

    obj.changes.should be_empty
    obj.scope1.test_string = 'new_test'
    obj.test_string = nil

    obj.changes[:meta].should eql([{'scope1__test_string' => 'test', 'test_string' => 'hey'}, {'scope1__test_string' => 'new_test'}])

    updates, deletes = obj.send(:_meta_changes)

    updates.should eql({'scope1__test_string' => 'new_test'})
    deletes.should eql(['test_string'])
  end

end