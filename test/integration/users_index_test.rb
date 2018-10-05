require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:lionelrishi)
    @non_admin = users(:anita)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "site should not show any inactive users profile" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "inactive@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    user = assigns(:user)
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    all_users = User.all
    assert_includes(all_users, user)
    get user_path(user)
    follow_redirect!
    assert_template 'home'
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    log_in_as(@admin)
    get user_path(user)
    assert_template 'users/show'
    get users_path
  end
end