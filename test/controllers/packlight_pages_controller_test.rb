require "test_helper"

class PacklightPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_one = users(:admin_one)
    @admin_two = users(:admin_two)
    @invited_user = users(:regular_user)
  end

  test "admin can view their own page" do
    sign_in @admin_one

    get packlight_page_path(packlight_id: @admin_one.packlight_id)

    assert_response :success
  end

  test "invited user can view the page they were invited to" do
    sign_in @invited_user

    get packlight_page_path(packlight_id: @admin_one.packlight_id)

    assert_response :success
  end

  test "authenticated but uninvited user is denied access" do
    sign_in @admin_two

    get packlight_page_path(packlight_id: @admin_one.packlight_id)

    assert_response :not_found
  end

  test "uninvited user can view a public page" do
    @admin_one.update!(packlight_public: true)
    sign_in @admin_two

    get packlight_page_path(packlight_id: @admin_one.packlight_id)

    assert_response :success
  end

  test "authenticated but uninvited user is denied access to an item" do
    sign_in @admin_two

    get packlight_item_path(packlight_id: @admin_one.packlight_id, id: items(:one).id)

    assert_response :not_found
  end

  test "logged-out visitor is redirected to sign in" do
    get packlight_page_path(packlight_id: @admin_one.packlight_id)

    assert_redirected_to new_user_session_path
  end

  test "revoking access denies a previously invited user" do
    sign_in @invited_user
    PacklightAccess.find_by(email: @invited_user.email, packlight_id: @admin_one.packlight_id).destroy

    get packlight_page_path(packlight_id: @admin_one.packlight_id)

    assert_response :not_found
  end
end
