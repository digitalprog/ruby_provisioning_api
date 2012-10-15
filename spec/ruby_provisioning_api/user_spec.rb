require 'spec_helper'
#require 'ruby_provisioning_api/user_mock'

describe RubyProvisioningApi::User do

  describe ".new" do

    context "passing a Hash" do

      before do
        @user = RubyProvisioningApi::User.new(:user_name => "foobar", :given_name => "Foo", :family_name => "Bar")
      end

      it "should initialize a new User" do
        @user.user_name.should be_eql("foobar")
        @user.given_name.should be_eql("Foo")
        @user.family_name.should be_eql("Bar")
      end

      it "should override the default value of suspended if passed through params" do
        user = RubyProvisioningApi::User.new(:user_name => "foobar", :given_name => "Foo", :family_name => "Bar", :suspended => true)
        user.should be_suspended
      end

      it "should not override the default value of suspended if not passed through params" do
        @user.should_not be_suspended
      end

      it "should override the default value of quota if passed through params" do
        user = RubyProvisioningApi::User.new(:user_name => "foobar", :given_name => "Foo", :family_name => "Bar", :quota => "333")
        user.quota.should be_eql("333")
      end

      it "should not override the default value of quota if not passed through params" do
        @user.quota.should be_eql("1024")
      end
    end

    context "step-by-step" do

      before do
        @user = RubyProvisioningApi::User.new
      end

      it "should initialize a new user with a step-by-step initialization" do
        @user.user_name = "foobar"
        @user.given_name = "Foo"
        @user.family_name = "Bar"
        @user.user_name.should be_eql("foobar")
        @user.given_name.should be_eql("Foo")
        @user.family_name.should be_eql("Bar")
      end

      it "should override the default value of suspended if assigned explicitly" do
        @user.suspended = true
        @user.should be_suspended
      end

      it "should not override the default value of suspended if not assigned explicitly" do
        @user.should_not be_suspended
      end

      it "should override the default value of quota if assigned explicitly" do
        @user.quota = "333"
        @user.quota.should be_eql("333")
      end

      it "should not override the default value of quota if not assigned explicitly" do
        @user.quota.should be_eql("1024")
      end

    end

  end


  describe ".find" do

    context "existing user" do

      before :all do
        VCR.use_cassette "create_and_find_user" do
          user = RubyProvisioningApi::User.new(:user_name => "foobar", :given_name => "Foo", :family_name => "Bar")
          user.save
          @user = RubyProvisioningApi::User.find("foobar")
        end
      end

      it "should return the expected user" do
        @user.user_name.should be_eql("foobar")
        @user.given_name.should be_eql("Foo")
        @user.family_name.should be_eql("Bar")
        @user.suspended.should be_eql("false")
      end

      it "should return a RubyProvisioningApi::User object" do
        @user.should be_kind_of(RubyProvisioningApi::User)
      end

    end

    context "non existing user" do

      it "should raise an exception if the user does not exist" do
        VCR.use_cassette "find_non_existing_user" do
          lambda {
            RubyProvisioningApi::User.find("ThIsUsErIsNoTvAlId")
          }.should raise_error(RubyProvisioningApi::Error, "Entity does not exist")
        end
      end
    end

  end

  describe ".all" do

    context "with existing users" do

      before :all do
        VCR.use_cassette "find_all_users_with_existing_users" do
          @users = RubyProvisioningApi::User.all
        end
      end

      it "should retrieve all the users in the domain" do
        @users.count.should be_eql(6) # May change depending on vcr files used
      end

      it "should return an Array" do
        @users.should be_kind_of(Array)
      end

      it "should return an Array of users" do
        @users.each do |user|
          user.should be_kind_of(RubyProvisioningApi::User)
        end
      end

    end

    # TODO: commented out ask Damiano if we can delete all users
    #context "with no existing users" do
    #
    #  before :all do
    #    VCR.use_cassette "delete_all_users_and_find_all" do
    #      @users = RubyProvisioningApi::User.all.each { |user| user.delete }
    #      @users = RubyProvisioningApi::User.all
    #    end
    #  end
    #
    #  it "should return an empty array" do
    #    @users.should be_empty
    #    @users.should be_kind_of(Array)
    #  end
    #
    #end

  end

  describe "#save" do

    before :all do
      @user = RubyProvisioningApi::User.new(:user_name => Faker::Internet.user_name, :given_name => Faker::Name.first_name, :family_name => Faker::Name.last_name)
      @user1 = RubyProvisioningApi::User.new(:user_name => Faker::Internet.user_name, :given_name => Faker::Name.first_name, :family_name => Faker::Name.last_name)
      @invalid_user = RubyProvisioningApi::User.new(:user_name => Faker::Internet.user_name, :given_name => Faker::Name.first_name)
    end

    # TODO: domain user limit exceeded
    it "should return true when saving a valid User" do
      VCR.use_cassette "save_a_valid_user" do
        @user.save.should be_eql(true)
      end
    end

    it "should save a new record if the username does not exist and return true" do
      VCR.use_cassette("users_before_save") { @users_before = RubyProvisioningApi::User.all }
      VCR.use_cassette "save_a_valid_user_2" do
        @user1.save.should be_eql(true)
      end
      VCR.use_cassette("users_after_save") { @users_after = RubyProvisioningApi::User.all }
      @users_before.length.should be_eql(@users_after.length - 1)
    end

    it "should return false when saving a non valid User" do
      @invalid_user.save.should be_eql(false)
    end

    context "on update" do

      before :all do
        VCR.use_cassette("update-find_user_foo_bar") do
          @foo_bar_before = RubyProvisioningApi::User.find("foobar")
        end
        VCR.use_cassette("update-users_before_update") do
          @users_before_update = RubyProvisioningApi::User.all
        end
        @foo_bar_before.user_name = "barfoo"
        @foo_bar_before.given_name = "ooF"
        @foo_bar_before.family_name = "raB"
        VCR.use_cassette("update-update_user_foobar") do
          @foo_bar_before.save
        end
        VCR.use_cassette("update-users_after_update") do
          @users_after_update = RubyProvisioningApi::User.all
        end
        VCR.use_cassette("update-find_user_foo_bar_after_update") do
          @foo_bar_after = RubyProvisioningApi::User.find("foobar")
        end
      end

      it "should not change the users count" do
        @users_after_update.length.should be_eql(@users_before_update.length)
      end

      it "should return barfoo when finding foobar" do
        @foo_bar_after.user_name.should be_eql("barfoo")
        @foo_bar_after.given_name.should be_eql("ooF")
        @foo_bar_after.family_name.should be_eql("raB")
      end

    end

  end

#end
#
#describe ".create" do
#
#end
#
#describe "#update_attributes" do
#
#end

end

