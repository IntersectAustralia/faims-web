require "spec_helper"

describe Notifier do
  
  describe "Email notifications to users should be sent" do
    it "should send mail to user if access request approved" do
      address = 'user@email.org'
      user = FactoryGirl.create(:user, :status => "A", :email => address)
      email = Notifier.notify_user_of_approved_request(user).deliver
  
      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false) 
      email.to.should eq([address])
      email.subject.should eq("faims - Your access request has been approved") 
    end

    it "should send mail to user if access request denied" do
      address = 'user@email.org'
      user = FactoryGirl.create(:user, :status => "A", :email => address)
      email = Notifier.notify_user_of_rejected_request(user).deliver
  
      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false) 
      email.to.should eq([address])
      email.subject.should eq("faims - Your access request has been rejected") 
    end
  end

  describe "Notification to superusers when new access request created"
  it "should send the right email" do
    address = 'user@email.org'
    user = FactoryGirl.create(:user, :status => "U", :email => address)
    User.should_receive(:get_superuser_emails) { ["super1@intersect.org.au", "super2@intersect.org.au"] }
    email = Notifier.notify_superusers_of_access_request(user).deliver

    # check that the email has been queued for sending
    ActionMailer::Base.deliveries.empty?.should eq(false)
    email.subject.should eq("faims - There has been a new access request")
    email.to.should eq(["super1@intersect.org.au", "super2@intersect.org.au"])
  end
 
end
