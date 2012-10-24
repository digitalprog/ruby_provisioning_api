require 'spec_helper'

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

      it "should initialize a new user" do
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
        @user.suspended.should be_false
      end

      it "should return a RubyProvisioningApi::User object" do
        @user.should be_kind_of(RubyProvisioningApi::User)
      end

    end

    context "non existing user" do

      it "should raise an exception" do
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
        @users.count.should be(5) # May change depending on vcr files used
      end

      it "should return an Array" do
        @users.should be_kind_of(Array)
      end

      it "should return an Array of User" do
        @users.each do |user|
          user.should be_kind_of(RubyProvisioningApi::User)
        end
      end

    end

    # Commented out: this test will delete all users
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

    it "should return true when saving a valid User" do
      VCR.use_cassette "save_a_valid_user" do
        @user.save.should be_true
      end
    end

    it "should save a new record if the username does not exist and return true" do
      VCR.use_cassette("users_before_save") { @users_before = RubyProvisioningApi::User.all }
      VCR.use_cassette "save_a_valid_user_2" do
        @user1.save.should be_true
      end
      VCR.use_cassette("users_after_save") { @users_after = RubyProvisioningApi::User.all }
      @users_before.length.should be_eql(@users_after.length - 1)
    end

    it "should return false when saving a non valid User" do
      @invalid_user.save.should be_false
    end

    context "on update" do

      before :all do
        VCR.use_cassette("update-find_user_foo_bar") { @foo_bar_before = RubyProvisioningApi::User.find("foobar") }
        VCR.use_cassette("update-users_before_update") { @users_before_update = RubyProvisioningApi::User.all }
        @foo_bar_before.user_name = "barfoo"
        @foo_bar_before.given_name = "ooF"
        @foo_bar_before.family_name = "raB"
        VCR.use_cassette("update-update_user_foobar") { @foo_bar_before.save }
        VCR.use_cassette("update-users_after_update") { @users_after_update = RubyProvisioningApi::User.all }
        # ASYNC: here it may be necessary to add a sleep to wait the update on google when running tests without vcr
        VCR.use_cassette("update-find_user_foo_bar_after_update") { @foo_bar_after = RubyProvisioningApi::User.find("foobar") }
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

  describe ".create" do

    before :all do
      VCR.use_cassette "create-create_and_find_foo2" do
        @retval = RubyProvisioningApi::User.create(:user_name => "foo2", :given_name => "foo2_name", :family_name => "foo2_surname")
        @saved_user = RubyProvisioningApi::User.find("foo2")
      end
      VCR.use_cassette "create-create_existing_user" do
        @existing_retval = RubyProvisioningApi::User.create(:user_name => "foo2", :given_name => "foo2_name", :family_name => "foo2_surname")
      end
    end

    it "should create a user if it does not exist" do
      @saved_user.user_name.should be_eql("foo2")
      @saved_user.given_name.should be_eql("foo2_name")
      @saved_user.family_name.should be_eql("foo2_surname")
    end

    it "should return true if the user was created successfully" do
      @retval.should be_true
    end

    it "should return true if the user already exists" do
      @existing_retval.should be_true
    end

  end

  describe "#update_attributes" do

    before do
      VCR.use_cassette "update_attributes-find_update_attributes_and_find_again" do
        user = RubyProvisioningApi::User.find("foobar")
        @retval = user.update_attributes(:user_name => "barfoo", :given_name => "ooF", :family_name => "raB")
        @updated_user = RubyProvisioningApi::User.find("barfoo")
      end
    end

    it "should update a user" do
      @updated_user.user_name.should be_eql("barfoo")
      @updated_user.given_name.should be_eql("ooF")
      @updated_user.family_name.should be_eql("raB")
    end

    it "should return true if the update succeeded" do
      @retval.should be_true
    end

    it "should raise error if assigning an existing username" do
      VCR.use_cassette "update_attributes-update_assigning_existing_username" do
        lambda {
          @updated_user.update_attributes(:user_name => "celestino.gaylord")
        }.should raise_error(RubyProvisioningApi::Error, "Entity exists")
      end

    end

  end

  describe "#suspend" do

    before :all do
      VCR.use_cassette "suspend-load_unsuspended_suspend_reload_resuspend_and_reload" do
        user = RubyProvisioningApi::User.find("barfoo")
        user.suspend
        @user = RubyProvisioningApi::User.find("barfoo")
        @user.suspend
        @resuspended_user = RubyProvisioningApi::User.find("barfoo")
      end
    end

    context "unsuspended user" do

      it "should suspend the user" do
        @user.should be_suspended
      end

    end

    context "already suspended user" do

      it "should leave the user suspended" do
        @resuspended_user.should be_suspended
      end

    end

  end

  describe "#restore" do

    before :all do
      VCR.use_cassette "restore-load_suspended_restore_reload_re-restore_and_reload" do
        user = RubyProvisioningApi::User.find("barfoo")
        user.restore
        @user = RubyProvisioningApi::User.find("barfoo")
        @user.restore
        @rerestored_user = RubyProvisioningApi::User.find("barfoo")
      end
    end

    context "suspended user" do

      it "should restore the user" do
        @user.should_not be_suspended
      end

    end

    context "unsuspended user" do

      it "should leave the user unsuspended" do
        @rerestored_user.should_not be_suspended
      end

    end

  end

  describe "#delete" do

    before :all do
      VCR.use_cassette "delete-find_all_delete_one_find_all" do
        @users_before = RubyProvisioningApi::User.all.map(&:user_name)
        user = RubyProvisioningApi::User.find("foo2")
        @retval = user.delete
        @users_after = RubyProvisioningApi::User.all.map(&:user_name)
      end
    end

    it "should delete a user" do
      (@users_before - @users_after).should be_eql(["foo2"])
      @users_before.length.should be(@users_after.length + 1)
    end

    it "should return true if the operation succeeded" do
      @retval.should be_true
    end

  end

  describe "#is_member_of?" do

    #before :all do
    #  VCR.use_cassette "is_member_of-find_group_add_member_is_member" do
    #    group = RubyProvisioningApi::Group.find("fake")
    #    group.add_member("barfoo")
    #    @retval_true = RubyProvisioningApi::User.find("barfoo").is_member_of?("fake")
    #    @retval_true = RubyProvisioningApi::User.find("barfoo").is_member_of?("test4")
    #  end
    #end
    #
    #it "should return true if the user is member of the given group" do
    #  @retval_true.should be_true
    #end
    #
    #it "should return false if the user isn't member of the given group"
    #it "should raise an exception if the given group does not exist"

  end

end

