require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_one = users(:admin_one)
    @admin_two = users(:admin_two)
    @invited_user = users(:regular_user)
    @item = items(:one)
  end

  test "invited user can subscribe to an item they have access to" do
    sign_in @invited_user

    assert_difference("Subscription.count", 1) do
      post packlight_item_subscription_path(packlight_id: @admin_one.packlight_id, item_id: @item.id)
    end

    assert_redirected_to packlight_item_path(packlight_id: @admin_one.packlight_id, id: @item.id)
  end

  test "uninvited user is denied access to subscribe" do
    sign_in @admin_two

    assert_no_difference("Subscription.count") do
      post packlight_item_subscription_path(packlight_id: @admin_one.packlight_id, item_id: @item.id)
    end

    assert_response :not_found
  end

  test "uninvited user is denied access to unsubscribe" do
    sign_in @admin_two

    delete packlight_item_subscription_path(packlight_id: @admin_one.packlight_id, item_id: @item.id)

    assert_response :not_found
  end
end
