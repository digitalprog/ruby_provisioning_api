require 'spec_helper'
require 'ruby_provisioning_api/user_mock'

describe RubyProvisioningApi::User do

  before :all do
    @mock = UserMock.new
  end

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

    before :all do
      @mock.user_list << RubyProvisioningApi::User.new(:user_name => "foobar", :given_name => "Foo", :family_name => "Bar")
      @mock.stub_find("foobar")
      @user = RubyProvisioningApi::User.find("foobar")
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

    it "should raise an exception if the user does not exist" do
      @mock.stub_find("fake")
      lambda { RubyProvisioningApi::User.find("fake") }.should raise_error(RubyProvisioningApi::Error, "Entity does not exist")
    end

  end

  describe ".all" do

    before :all do
      @mock.user_list = []
      3.times { @mock.user_list << RubyProvisioningApi::User.new(:user_name => Faker::Internet.user_name, :given_name => Faker::Name.first_name, :family_name => Faker::Name.last_name) }
      @mock.stub_all
      @users = RubyProvisioningApi::User.all
    end

    context "with no existing user" do

      before do
        @mock.user_list = []
        @mock.stub_all
        @users = RubyProvisioningApi::User.all
      end

      it "should return an empty array" do
        @users.should be_empty
        @users.should be_kind_of(Array)
      end

    end

    it "should retrieve all the users in the domain" do
      @users.count.should be_eql(3)
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

  describe "#save" do



    it "should return true when saving a valid User"
    it "should save a new record if the username does not exist"
    it "should return false when saving a non valid User"
    it "should save an invalid user when passing :validate => false"
    it "should not change the users count when performing an update"

  end

  describe ".create" do

  end

  describe "#update_attributes" do

  end

end

