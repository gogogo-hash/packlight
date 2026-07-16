require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_one = users(:admin_one)
    @admin_two = users(:admin_two)
    @invited_user = users(:regular_user)
    @item = items(:one)
  end

  test "admin can comment on their own item" do
    sign_in @admin_one

    assert_difference("Comment.count", 1) do
      post packlight_item_comments_path(packlight_id: @admin_one.packlight_id, item_id: @item.id),
        params: { comment: { content: "Nice item!" } }
    end

    assert_redirected_to packlight_item_path(packlight_id: @admin_one.packlight_id, id: @item.id)
  end

  test "invited user can comment on an item they have access to" do
    sign_in @invited_user

    assert_difference("Comment.count", 1) do
      post packlight_item_comments_path(packlight_id: @admin_one.packlight_id, item_id: @item.id),
        params: { comment: { content: "Nice item!" } }
    end

    assert_redirected_to packlight_item_path(packlight_id: @admin_one.packlight_id, id: @item.id)
  end

  test "uninvited user is denied access to comment" do
    sign_in @admin_two

    assert_no_difference("Comment.count") do
      post packlight_item_comments_path(packlight_id: @admin_one.packlight_id, item_id: @item.id),
        params: { comment: { content: "Sneaky comment" } }
    end

    assert_response :not_found
  end
end
