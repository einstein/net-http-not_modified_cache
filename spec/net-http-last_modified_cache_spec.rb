require File.expand_path('../spec_helper', __FILE__)

describe Net::HTTP::LastModifiedCache do
  before { subject.enable! }

  context '#cacheable_request?' do
    let(:request) { Net::HTTP::Get.allocate }

    it 'should only return true if enabled' do
      subject.disable!
      subject.cacheable_request?(request).should be_false
      subject.enable!
      subject.cacheable_request?(request).should be_true
    end

    it 'should only return true if request method is a Net::HTTP::Get' do
      subject.cacheable_request?(nil).should be_false
      subject.cacheable_request?(Object.new).should be_false
      subject.cacheable_request?(Net::HTTP::Post.allocate).should be_false
      subject.cacheable_request?(request).should be_true
    end
  end

  context '#cacheable_response?' do
    let(:found_response) { response.dup.tap { |response| response.stub!(:code).and_return('200') } }
    let(:not_modified_response) { response.dup.tap { |response| response.stub!(:code).and_return('304') } }
    let(:response) { Net::HTTPResponse.allocate }

    it 'should only return true if enabled' do
      subject.disable!
      subject.cacheable_response?(found_response).should be_false
      subject.enable!
      subject.cacheable_response?(found_response).should be_true
    end

    it 'should only return true if response code is a 200 or 304' do
      subject.cacheable_response?(response).should be_false
      subject.cacheable_response?(found_response).should be_true
      subject.cacheable_response?(not_modified_response).should be_true
    end
  end

  context '#enabled?' do
    it 'should be toggleable and true by default' do
      subject.enabled?.should be_true
      subject.disable!
      subject.enabled?.should be_false
      subject.enable!
      subject.enabled?.should be_true
    end
  end

  context '#process_request!' do
  end

  context '#process_response!' do
  end

  context '#root' do
    it 'should be /tmp by default' do
      subject.root.should == '/tmp'
    end
  end

  context '#store' do
    it 'should be an ActiveSupport::Cache::FileStore by default' do
      subject.store.should be_an_instance_of(ActiveSupport::Cache::FileStore)
    end

    it 'should use root as cache root' do
      subject.store.cache_path.should == subject.root
    end
  end

  context '#version' do
    it 'should return a version string' do
      subject.version.should match(/^\d+\.\d+\.\d+(\.[^\.]+)?$/)
    end
  end

  context '#while_disabled' do
    it 'should set enabled? to false for the duration of the block' do
      subject.while_disabled { subject.enabled?.should be_false }
      subject.enabled?.should be_true
    end
  end

  context '#while_enabled' do
    it 'should set enabled? to true for the duration of the block' do
      subject.disable!
      subject.while_enabled { subject.enabled?.should be_true }
      subject.enabled?.should be_false
    end
  end

  context '#while_enabled_is' do
    it 'should set enabled? and return it back to its previous value after evaluating the block' do
      subject.while_enabled_is(false) { subject.enabled?.should be_false }
      subject.enabled?.should be_true

      subject.disable!
      subject.while_enabled_is(true) { subject.enabled?.should be_true }
      subject.enabled?.should be_false
    end
  end

  context '#with_store' do
    let(:store) { ActiveSupport::Cache.lookup_store(:file_store, '/tmp/test') }

    it 'should switch lookup store when yielding' do
      current_store = subject.store
      subject.with_store(store) { subject.store.should_not == current_store }
      subject.store.should == current_store
    end
  end

  context '::Entry' do
    it 'instance should respond to body and last_modified_at' do
      subject::Entry.new.should respond_to(:body)
      subject::Entry.new.should respond_to(:last_modified_at)
    end
  end
end