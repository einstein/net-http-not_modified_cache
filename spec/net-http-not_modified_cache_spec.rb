require File.expand_path('../spec_helper', __FILE__)

describe Net::HTTP::NotModifiedCache do
  let(:lmc) { Net::HTTP::NotModifiedCache }

  context 'when included in Net::HTTP' do
    subject { Net::HTTP.new(url.host) }

    let(:found) { response.dup.tap { |response| response.stub!(:code).and_return('200') } }
    let(:not_modified) { response.dup.tap { |response| response.stub!(:code).and_return('304') } }
    let(:response) { Net::HTTPResponse.allocate }

    let(:get) { Net::HTTP::Get.allocate }
    let(:post) { Net::HTTP::Post.allocate }
    let(:request) { Net::HTTP::Get.new(url.path) }
    let(:url) { URI.parse('http://fakeweb.test/index.html') }

    context '#cache_entry' do
      let(:stubbed_response) do
        found.tap do |response|
          response.stub!(:body).and_return('test')
          response.instance_variable_set('@header', {})
        end
      end

      it 'should return an Entry instance' do
        subject.cache_entry(stubbed_response).should be_an_instance_of(lmc::Entry)
      end

      it 'should set body to the response body' do
        subject.cache_entry(stubbed_response).body.should == stubbed_response.body
      end

      it 'should set last_modified_at to last-modified header if it exists' do
        time = Time.now - 100
        stubbed_response['last-modified'] = time.httpdate
        stubbed_response['date'] = (time - 100).httpdate
        subject.cache_entry(stubbed_response).last_modified_at.httpdate.should == time.httpdate
      end

      it 'should set last_modified_at to date header if it exists and last-modified header is not specified' do
        time = Time.now - 200
        stubbed_response['date'] = time.httpdate
        subject.cache_entry(stubbed_response).last_modified_at.httpdate.should == time.httpdate
      end

      it 'should set last_modified_at to Time.now if both last-modified and date headers are not specified' do
        Timecop.freeze(Time.now - 500) { subject.cache_entry(stubbed_response).last_modified_at.httpdate.should == Time.now.httpdate }
      end
    end

    context '#cache_key' do
      it 'should join the address and request path' do
        subject.cache_key(request).should == [subject.address, request.path].join
      end
    end

    context '#cache_request' do
      it 'should only call #cache_request! if request is cacheable' do
        subject.should_receive(:cache_request!)
        subject.cache_request(get, 'test')

        subject.should_not_receive(:cache_request!)
        subject.cache_request(post, 'test')
      end
    end

    context '#cache_request!' do
      it 'should add last-modified header if cached entry exists'
      it "should not add last-modified header if cached entry doesn't exist"
      it 'should not modify last-modified header if it already exists'
    end

    context '#cacheable_request?' do
      it 'should only return true if enabled' do
        lmc.disable!
        subject.cacheable_request?(get).should be_false
        lmc.enable!
        subject.cacheable_request?(get).should be_true
      end

      it 'should only return true if request is a Net::HTTP::Get' do
        subject.cacheable_request?(get).should be_true
        subject.cacheable_request?(post).should be_false
      end
    end

    context '#cache_response' do
      it 'should only call #cache_response! if response is cacheable' do
        subject.should_receive(:cache_response!)
        subject.cache_response(found, 'test')

        subject.should_not_receive(:cache_response!)
        subject.cache_response(response, 'test')
      end
    end

    context '#cache_response!' do
      it 'should cache body if response is a 200'
      it 'should set cached body if response is a 304'
    end

    context '#cacheable_response?' do
      it 'should only return true if enabled' do
        lmc.disable!
        subject.cacheable_response?(found).should be_false
        lmc.enable!
        subject.cacheable_response?(found).should be_true
      end

      it 'should only return true if response code is a 200 or 304' do
        subject.cacheable_response?(response).should be_false
        subject.cacheable_response?(found).should be_true
        subject.cacheable_response?(not_modified).should be_true
      end
    end

    context '#request_with_not_modified_cache' do
      it 'should run fakeweb tests'
    end
  end

  context '.enabled?' do
    it 'should be toggleable and true by default' do
      subject.enabled?.should be_true
      subject.disable!
      subject.enabled?.should be_false
      subject.enable!
      subject.enabled?.should be_true
    end
  end

  context '.root' do
    it 'should be /tmp/net-http-not_modified_cache by default' do
      subject.root.should == '/tmp/net-http-not_modified_cache'
    end
  end

  context '.store' do
    it 'should be an ActiveSupport::Cache::FileStore by default' do
      subject.store.should be_an_instance_of(ActiveSupport::Cache::FileStore)
    end

    it 'should use root as cache root' do
      subject.store.cache_path.should == subject.root
    end
  end

  context '.version' do
    it 'should return a version string' do
      subject.version.should match(/^\d+\.\d+\.\d+(\.[^\.]+)?$/)
    end
  end

  context '.while_disabled' do
    it 'should set enabled? to false for the duration of the block' do
      subject.while_disabled { subject.enabled?.should be_false }
      subject.enabled?.should be_true
    end
  end

  context '.while_enabled' do
    it 'should set enabled? to true for the duration of the block' do
      subject.disable!
      subject.while_enabled { subject.enabled?.should be_true }
      subject.enabled?.should be_false
    end
  end

  context '.while_enabled_is' do
    it 'should set enabled? and return it back to its previous value after evaluating the block' do
      subject.while_enabled_is(false) { subject.enabled?.should be_false }
      subject.enabled?.should be_true

      subject.disable!
      subject.while_enabled_is(true) { subject.enabled?.should be_true }
      subject.enabled?.should be_false
    end
  end

  context '.with_store' do
    let(:store) { ActiveSupport::Cache.lookup_store(:file_store, '/tmp/test') }

    it 'should switch lookup store when yielding' do
      current_store = subject.store
      subject.with_store(store) { subject.store.should_not == current_store }
      subject.store.should == current_store
    end
  end

  context '::Entry' do
    subject { lmc::Entry.new }

    it 'should respond to body and last_modified_at' do
      subject.should respond_to(:body)
      subject.should respond_to(:last_modified_at)
    end
  end
end