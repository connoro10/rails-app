# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name:"connor", email: "connor@gmail.com", password: "bazinga", password_confirmation: "bazinga")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "m" * 244 +"@example.com"
    assert_not @user.valid?
  end
  
  test "valid addresses are accepted" do
    addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    addresses.each do |a|
      @user.email = a
      assert @user.valid?, "#{a} is a valid address"
    end
  end
  
  test "these emails should be rejected" do
    addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com fubar@gmail..com]
    addresses.each do |a|
      @user.email = a
      assert_not @user.valid?, "#{a} should not be a valid email address bro"
    end
  end
  
  test "duplicate email should not be valid" do
    duper = @user.dup
    @user.save
    duper.email.upcase!
    assert_not duper.valid?
  end
  
    test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  
  test "password should not be blank" do
    @user.password = @user.password_confirmation = "   "
    assert_not @user.valid?
  end
  
  test "password needs more than 6 characters" do
    @user.password = @user.password_confirmation = "nip"
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end
end
