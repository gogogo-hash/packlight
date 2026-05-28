class ChangeDescriptionAndPriceInItems < ActiveRecord::Migration[8.1]
  def change
    change_column_null :items, :description, true
    change_column_null :items, :price, true
  end
end
