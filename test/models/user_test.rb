require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "packlight_public defaults to false" do
    assert_not users(:admin_one).packlight_public?
  end

  test "packlight_public can be toggled true" do
    admin = users(:admin_one)
    admin.update!(packlight_public: true)

    assert admin.reload.packlight_public?
  end
end
