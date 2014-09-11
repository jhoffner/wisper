require 'spec_helper'
require 'wisper/rspec/matchers'

RSpec::configure do |config|
  config.include(Wisper::Rspec::BroadcastMatcher)
end

describe 'broadcast matcher' do
  it 'passes when publisher broadcasts inside block' do
    publisher = publisher_class.new
    expect { publisher.send(:broadcast, :foobar) }.to broadcast(:foobar)
  end

  it 'passes with not_to when publisher does not broadcast inside block' do
    publisher = publisher_class.new
    expect { publisher }.not_to broadcast(:foobar)
  end

  it 'passes when specified publisher broadcasts inside block' do
    publisher = publisher_class.new
    expect { publisher.send(:broadcast, :foobar) }.to broadcast(publisher, :foobar)
  end
end
