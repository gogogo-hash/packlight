require "test_helper"

class Admin::PacklightSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_one)
  end

  test "admin can turn on public visibility" do
    sign_in @admin

    patch admin_packlight_settings_path, params: { user: { packlight_public: true } }, as: :turbo_stream

    assert @admin.reload.packlight_public?
    assert_response :success
  end

  test "admin can turn off public visibility" do
    @admin.update!(packlight_public: true)
    sign_in @admin

    patch admin_packlight_settings_path, params: { user: { packlight_public: false } }, as: :turbo_stream

    assert_not @admin.reload.packlight_public?
  end

  test "html request redirects back to admin items" do
    sign_in @admin

    patch admin_packlight_settings_path, params: { user: { packlight_public: true } }

    assert_redirected_to admin_items_path
  end
end
