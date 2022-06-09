# frozen_string_literal: true

class AddApprovalToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :approval, :string
  end
end
