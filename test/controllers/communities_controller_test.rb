require "test_helper"

class CommunitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_one = users(:admin_one)
    @admin_two = users(:admin_two)
    @regular_user = users(:regular_user)
  end

  test "public communities excludes packlights already accessible via invite" do
    @admin_one.update!(packlight_public: true) # regular_user already has an invite to admin_one
    @admin_two.update!(packlight_public: true) # not invited

    sign_in @regular_user
    get communities_path

    assert_response :success
    public_users = @controller.instance_variable_get(:@public_users)
    assert_includes public_users, @admin_two
    assert_not_includes public_users, @admin_one
  end

  test "public communities excludes the current user's own packlight" do
    @regular_user.update!(packlight_public: true)

    sign_in @regular_user
    get communities_path

    assert_not_includes @controller.instance_variable_get(:@public_users), @regular_user
  end
end
