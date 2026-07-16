class RenameAdminToBetaCohortOnUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :admin, :beta_cohort
  end
end
