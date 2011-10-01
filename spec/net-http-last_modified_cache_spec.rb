require File.expand_path('../spec_helper', __FILE__)

describe Net::HTTP::LastModifiedCache do
  context '#enabled?' do
    it 'should be toggleable and true by default' do
      subject.enabled?.should be_true
      subject.disable!
      subject.enabled?.should be_false
      subject.enable!
      subject.enabled?.should be_true
    end
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
      puts subject.store.cache_path.should == subject.root
    end
  end
end