require 'spec_helper'

describe MetaContent::Dsl do

  let(:clath){ MetaObject }
  let(:dsl){ MetaContent::Dsl.new(clath) }

  it 'creates basic accessors when invoked' do
    dsl.integer :id, :user_id
    clath.instance_methods.map(&:to_sym).should include(:id, :user_id)

    instance = clath.new

    instance.id = 12
    instance.id.should eql(12)

    instance.user_id = 44
    instance.user_id.should eql(44)
  end

  it 'allows for nesting to occur' do
    dsl.meta :whatever do
      integer :test
    end

    clath.instance_methods.map(&:to_sym).should include(:whatever)
    instance = clath.new
    instance.whatever.test = 44

    instance.whatever.is_a?(MetaContent::Proxy).should be_true
    instance.whatever.test.should eql(44)
  end

  context "typecasting" do

    after do
      clath.new.send("test_type").should eql(@type.to_sym)
    end

    MetaContent::Dsl::FIELD_TYPES.each do |type|
      it "provides a shortcut to create a #{type} field" do
        @type = type
        dsl.send(type, :test)
      end

      it "allows the field to be set by passing the :type option as #{type}" do
        @type = type
        dsl.field :test, :type => type
      end
    end
  end

end