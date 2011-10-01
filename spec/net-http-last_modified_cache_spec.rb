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
end