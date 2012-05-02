require 'spec_helper'

describe Report do
  it "should send a standard message" do
    r = Report.msg(:to => "test@example.com", :subject => "test email", :message => "This is the body text")
    r.to.should == ["test@example.com"]
    r.subject.should == "test email"
    r.body.raw_source.should == "This is the body text"
  end
  it "should send a blank message when no text is proved (e.g. subject is message)" do
    r = Report.msg(:to => "test@example.com", :subject => "test email")
    r.to.should == ["test@example.com"]
    r.subject.should == "test email"
    r.body.raw_source.should be_blank
  end
end
  