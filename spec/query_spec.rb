require 'spec_helper'

describe MetaContent::Query do

  let(:obj){ MetaObject.new }
  let(:query){ MetaContent::Query.new(obj) }

  before do
    query.stub(:pk).and_return(30)
    query.stub(:qtn).and_return('`metas`')
    query.stub(:quote) do |val|
      "``#{val}``"
    end
  end

  it 'correctly selects all the values based on the provided record' do
    query.should_receive(:execute).with("SELECT `metas`.lookup, `metas`.value FROM `metas` WHERE `metas`.object_id = ``30``").and_return([])
    query.select_all
  end

  it 'correctly updates_all when provided changes' do
    query.should_receive(:execute).with("INSERT INTO `metas`(object_id,lookup,value) VALUES (``30``,``a``,``aval``),(``30``,``b``,``bval``) ON DUPLICATE KEY UPDATE value = VALUES(value)")
    h = ActiveSupport::OrderedHash.new
    h[:a] = 'aval'
    h[:b] = 'bval'
    query.update_all(h)
  end

  it 'correctly deletes all' do
    query.should_receive(:execute).with("DELETE FROM `metas` WHERE `metas`.object_id = ``30`` AND `metas`.lookup IN (``a``,``b``)")
    query.delete_all([:a, :b])
  end
    
end