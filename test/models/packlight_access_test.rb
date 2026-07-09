require "test_helper"

class PacklightAccessTest < ActiveSupport::TestCase
  test "normalizes email by stripping and downcasing before validation" do
    access = PacklightAccess.new(email: "  Guest@Example.com  ", packlight_id: "abc12345")
    access.valid?

    assert_equal "guest@example.com", access.email
  end

  test "is invalid without an email" do
    access = PacklightAccess.new(packlight_id: "abc12345")

    assert_not access.valid?
    assert_includes access.errors[:email], "can't be blank"
  end

  test "is invalid with a malformed email" do
    access = PacklightAccess.new(email: "not-an-email", packlight_id: "abc12345")

    assert_not access.valid?
    assert_includes access.errors[:email], "is invalid"
  end

  test "is invalid without a packlight_id" do
    access = PacklightAccess.new(email: "guest@example.com")

    assert_not access.valid?
    assert_includes access.errors[:packlight_id], "can't be blank"
  end

  test "enforces uniqueness of email scoped to packlight_id" do
    PacklightAccess.create!(email: "guest@example.com", packlight_id: "abc12345")
    duplicate = PacklightAccess.new(email: "GUEST@example.com", packlight_id: "abc12345")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "allows the same email across different packlight_ids" do
    PacklightAccess.create!(email: "guest@example.com", packlight_id: "abc12345")
    other = PacklightAccess.new(email: "guest@example.com", packlight_id: "xyz98765")

    assert other.valid?
  end
end
