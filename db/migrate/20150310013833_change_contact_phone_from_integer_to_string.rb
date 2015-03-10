class ChangeContactPhoneFromIntegerToString < ActiveRecord::Migration
  def up
    change_column :contacts, :phone, :string
  end

  def down
    change_column :contacts, :phone, :integer
  end
end
