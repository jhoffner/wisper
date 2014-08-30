require 'spec_helper'

describe Wisper do
  before do
    # assign the stderr to a new StringIO to test errors
    @orig_stderr, $stderr = $stderr, StringIO.new
  end

  after do
    # reassign the stderr to the original <IO:<STDERR>> instead of StringIO
    # used for testing
    $stderr = @orig_stderr
  end

  it 'includes Wisper::Publisher for backwards compatibility' do
    publisher_class = Class.new { include Wisper }
    expect(publisher_class.ancestors).to include Wisper::Publisher

    $stderr.rewind
    expect($stderr.gets.chomp).to include 'DEPRECATION'
  end

  # NOTE .with_listeners is deprecated
  it '.with_listeners subscribes listeners to all broadcast events for the duration of block' do
    publisher = publisher_class.new
    listener = double('listener')

    Wisper.with_listeners(listener) do
      publisher.send(:broadcast, 'im_here')
    end

    $stderr.rewind
    expect($stderr.string.chomp).to include 'DEPRECATION'
  end

  # NOTE .add_listener is deprecated
  it '.add_listener adds a global listener' do
    listener = double('listener')

    Wisper.add_listener(listener)

    $stderr.rewind
    expect($stderr.string.chomp).to include 'DEPRECATION'
  end

  describe '.subscribe' do
    context 'given block' do
      it 'subscribes listeners to all events for duration of the block' do
        publisher = publisher_class.new
        listener = double('listener')

        expect(listener).to receive(:im_here)
        expect(listener).not_to receive(:not_here)

        Wisper.subscribe(listener) do
          publisher.send(:broadcast, 'im_here')
        end

        publisher.send(:broadcast, 'not_here')
      end
    end

    context 'no block given' do
      it 'subscribes a listener to all events' do
        listener = double('listener')
        Wisper.subscribe(listener)
        expect(Wisper::GlobalListeners.listeners).to eq [listener]
      end

      it 'subscribes multiple listeners to all events' do
        listener_1 = double('listener')
        listener_2 = double('listener')
        listener_3 = double('listener')

        Wisper.subscribe(listener_1, listener_2)

        expect(Wisper::GlobalListeners.listeners).to include listener_1, listener_2
        expect(Wisper::GlobalListeners.listeners).not_to include listener_3
      end
    end
  end
end
