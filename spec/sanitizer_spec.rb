require 'spec_helper'
\
describe MetaContent::Sanitizer do

  t = Time.now

  TESTS = [
    # type, val, in, out
    [:string, 'anything', 'anything', 'anything'],
    [:string, 44, '44', '44'],
    [:sym, :a, 'a', :a],
    [:string, nil, '', ''],
    [:integer, '50', '50', 50],
    [:integer, 33.4, '33.4', 33],
    [:integer, 'test', 'test', 0],
    [:int, '30.3', '30.3', 30],
    [:boolean, 'fail', '0', false],
    [:boolean, 'yes', '1', true],
    [:boolean, 'no', '0', false],
    [:boolean, true, '1', true],
    [:boolean, false, '0', false],
    [:date, t.to_date, t.to_date.to_time.to_i.to_s, t.to_date],
    [:date, t.to_i, t.to_i.to_s, t.to_date],
    [:datetime, t, t.to_i.to_s, t],
    [:datetime, t.to_i, t.to_i.to_s, t],
    [:float, 30, '30', 30.0],
    [:float, '50', '50', 50.0],
    [:float, 33.3, '33.3', 33.3],
    [:array, [:a, :b], %w(a b).to_json, %w(a b)],
    [:array, :a, %w(a).to_json, %w(a)],
    [:array, nil, '[]', []],
    [:array, [nil], '[null]', [nil]],
    [:hash, {:a => 'b'}, {:a => 'b'}.to_json, {'a' => 'b'}],
    [:range, (0..10), [0, 10, false].to_json, (0..10)],
    [:range, (0...10), [0, 10, true].to_json, (0...10)],
    [:json, {:a => 'b'}, {:a => 'b'}.to_json, {'a' => 'b'}]
  ]


  let(:obj){ MetaObject.new }
  let(:san){ MetaContent::Sanitizer.new(obj) }

  describe '#sanitize_in' do

    TESTS.each do |type, val, sin, sout|

      it [type, val, sin, sout].map{|v| "#{v} (#{v.class})" }.join(', ') do
        san.send(:sanitize_in, val, type).should eql(sin)
      end

    end

  end

  describe "#sanitize_out" do

    TESTS.each do |type, val, sin, sout|

      it [type, val, sin, sout].map{|v| "#{v} (#{v.class})" }.join(', ') do
        if [Time, DateTime, Date].include?(sout.class)
          san.send(:sanitize_out, sin, type).to_s.should eql(sout.to_s)
        else
          san.send(:sanitize_out, sin, type).should eql(sout)
        end
      end

    end

  end

  describe "#type_from_key" do

    it 'should correctly determine the type of the key' do
      san.send(:type_from_key, 'test_string').should eql(:string)
      san.send(:type_from_key, 'test_int').should eql(:int)
      san.send(:type_from_key, 'scope1__test_string').should eql(:string)
      san.send(:type_from_key, 'scope1__test_int').should eql(:int)
    end

  end
    
end