require 'spec_helper'

describe Report do
  it "should send a standard message" do
    r = Report.msg(:to => "test@example.com", :subject => "test email", :message => "This is the body text")
    expect(r.to).to eq(["test@example.com"])
    expect(r.subject).to eq("test email")
    expect(r.body.raw_source).to eq("This is the body text")
  end
  it "should send a blank message when no text is proved (e.g. subject is message)" do
    r = Report.msg(:to => "test@example.com", :subject => "test email")
    expect(r.to).to eq(["test@example.com"])
    expect(r.subject).to eq("test email")
    expect(r.body.raw_source).to be_blank
  end
end
  