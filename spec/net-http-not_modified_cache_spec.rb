require File.expand_path('../spec_helper', __FILE__)

describe Net::HTTP::NotModifiedCache do
  let(:nmc) { Net::HTTP::NotModifiedCache }

  context 'when included in Net::HTTP' do
    subject { Net::HTTP.new(url.host) }

    let(:found) do
      instance = response.dup
      instance.instance_variable_set('@body', 'test')
      instance.stub!(:code).and_return('200')
      instance
    end
    let(:not_modified) do
      instance = response.dup
      instance.stub!(:code).and_return('304')
      instance
    end
    let(:response) do
      instance = Net::HTTPResponse.allocate
      instance.instance_variable_set('@body', '')
      instance.instance_variable_set('@header', {})
      instance.instance_variable_set('@read', true)
      instance
    end

    let(:get) { Net::HTTP::Get.allocate }
    let(:post) { Net::HTTP::Post.allocate }
    let(:request) { Net::HTTP::Get.new(url.path) }

    let(:key) { subject.cache_key(get) }
    let(:url) { URI.parse('http://fakeweb.test/index.html') }

    context '#cache_entry' do
      it 'should return an Entry instance' do
        subject.cache_entry(found).should be_an_instance_of(nmc::Entry)
      end

      it 'should set body to the response body' do
        subject.cache_entry(found).body.should == found.body
      end

      it 'should set etag header if it exists' do
        subject.cache_entry(found).etag.should be_nil

        found['etag'] = 'test'
        subject.cache_entry(found).etag.should == 'test'
      end

      it 'should set last_modified_at to last-modified header if it exists' do
        time = Time.now - 100
        found['last-modified'] = time.httpdate
        found['date'] = (time - 100).httpdate
        subject.cache_entry(found).last_modified_at.httpdate.should == time.httpdate
      end

      it 'should set last_modified_at to date header if it exists and last-modified header is not specified' do
        time = Time.now - 200
        found['date'] = time.httpdate
        subject.cache_entry(found).last_modified_at.httpdate.should == time.httpdate
      end

      it 'should set last_modified_at to Time.now if both last-modified and date headers are not specified' do
        Timecop.freeze(Time.now - 500) { subject.cache_entry(found).last_modified_at.httpdate.should == Time.now.httpdate }
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
        subject.cache_request(get)

        subject.should_not_receive(:cache_request!)
        subject.cache_request(post)
      end
    end

    context '#cache_request!' do
      it 'should not add if-modified-since or if-none-match header if either already exists' do
        nmc.store.should_not_receive(:read)

        request['if-none-match'] = 'etag'
        subject.cache_request!(request)

        request['if-none-match'] = nil
        request['if-modified-since'] = Time.now.httpdate
        subject.cache_request!(request)
      end

      it 'should search for cached entry' do
        nmc.store.should_receive(:read)
        subject.cache_request!(request)
      end

      it 'should set etag and if-modified-since headers' do
        entry = nmc::Entry.new('testing', 'test', Time.now)
        nmc.store.should_receive(:read).with(subject.cache_key(request)).and_return(entry)
        subject.cache_request!(request)

        request['if-none-match'].should == entry.etag
        request['if-modified-since'].should == entry.last_modified_at.httpdate
      end
    end

    context '#cacheable_request?' do
      it 'should only return true if enabled' do
        nmc.disable!
        subject.cacheable_request?(get).should be_false
        nmc.enable!
        subject.cacheable_request?(get).should be_true
      end

      it 'should only return true if request is a Net::HTTP::Get' do
        subject.cacheable_request?(get).should be_true
        subject.cacheable_request?(post).should be_false
      end
    end

    context '#cache_response' do
      it 'should only be called if request is cacheable' do
        subject.stub(:request_without_not_modified_cache)
        subject.should_not_receive(:cache_response)
        subject.request(post)
      end

      it 'should only call #cache_response! if response is cacheable' do
        subject.should_receive(:cache_response!)
        subject.cache_response(found, 'test')

        subject.should_not_receive(:cache_response!)
        subject.cache_response(response, 'test')
      end
    end

    context '#cache_response!' do
      it 'should cache entry if response is a 200' do
        nmc.store.should_receive(:write)
        subject.cache_response!(found, key)
      end

      it 'should set cached body if response is a 304' do
        entry = nmc::Entry.new('testing', nil, Time.now)
        nmc.store.should_receive(:read).with(key).and_return(entry)
        subject.cache_response!(not_modified, key)
        not_modified.body.should == entry.body
      end
    end

    context '#cacheable_response?' do
      it 'should only return true if enabled' do
        nmc.disable!
        subject.cacheable_response?(found).should be_false
        nmc.enable!
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
    subject { nmc::Entry.new }

    it 'should respond to :body, :etag, and :last_modified_at' do
      subject.should respond_to(:body)
      subject.should respond_to(:etag)
      subject.should respond_to(:last_modified_at)
    end
  end
end