require 'spec_helper'

describe RubyProvisioningApi::Group do

  describe ".new" do

    context "passing a hash" do

      it "should initialize a new Group"

    end

    context "step-by-step" do

      it "should initialize a new Group"

    end

  end

  describe ".find" do

    context "existing Group" do

      it "should return the expected Group"
      it "should return a RubyProvisioningApi::Group object"

    end

    context "non existing Group" do

      it "should raise an exception"

    end

  end

  describe ".all" do

    context "with existing groups" do

      it "should retrieve all the groups in the domain"
      it "should return an Array"
      it "should return an Array of Group"

    end

    context "with no existing groups" do

      it "should return an empty array"

    end

  end

  describe "#save" do

    it "should return true when saving a valid Group"
    it "should save a new record if the group_id does not exist and return true"
    it "should return false when saving a non valid Group"

    context "on update" do

      it "should not change the groups count"

    end

  end

  describe ".create" do

    it "should create a Group if it does not exist"
    it "should return true if the Group was created successfully"
    it "should return true if the Group already exists" # TODO: check this assertion

  end

  describe "#update_attributes" do

    it "should update a Group"
    it "should return true if the update succeeded"
    it "should raise error if assigning an existing group_id" # TODO: check this assertion

  end

  describe "#delete" do

    it "should delete a Group"
    it "should return true if the operation succeeded"

  end

end