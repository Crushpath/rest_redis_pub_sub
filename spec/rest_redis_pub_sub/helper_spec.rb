require 'spec_helper'

describe RestRedisPubSub::Helper do

  describe ".camelize" do
    it "should camelize a given word" do
      expected_results = {
        'product' => 'Product',
        'product_created' => 'ProductCreated'
      }
      expected_results.each do |k,v|
        expect(described_class.camelize(k)).to eq(v)
      end
    end
  end

  describe ".constantize_if_defined" do
    it "should return constanst if exists" do
      expect(described_class.constantize_if_defined('RestRedisPubSub')).to eq(RestRedisPubSub)
      expect(described_class.constantize_if_defined('UnknowClass')).to be_nil
    end
  end

end
