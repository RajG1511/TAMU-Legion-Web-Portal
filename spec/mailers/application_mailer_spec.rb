require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  it "inherits from ActionMailer::Base" do
    expect(described_class < ActionMailer::Base).to be true
  end

  it "has the default from address set" do
    expect(described_class.default[:from]).to eq("from@example.com")
  end
end