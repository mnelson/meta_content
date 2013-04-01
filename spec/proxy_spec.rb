require 'spec_helper'

describe MetaContent::Proxy do

  let(:obj){ MetaObject.new }

  it 'should produce the correct scope' do
    obj.scope1.class._meta_scope.should eql('scope1')
  end

  it 'should respond to the accessors which were defined in the meta block' do
    obj.scope1.methods.map(&:to_sym).should include(:test_string, :test_int, :test_string=, :test_int=)
  end

  it 'should provide a meta method on the instance which provides back all the accessors as a hash' do
    obj.scope1.test_string = 'stringval'
    obj.scope1.test_int    = 44
    obj.scope1.meta[:test_string].should eql('stringval')
    obj.scope1.meta[:test_int].should eql(44)
  end

  it 'should allow nesting properly by providing the meta_object' do
    obj.changes.keys.should_not include(:meta)
    obj.scope1.subscope1.test_string = 'test'
    obj.changes.keys.should include(:meta)
  end
  
end