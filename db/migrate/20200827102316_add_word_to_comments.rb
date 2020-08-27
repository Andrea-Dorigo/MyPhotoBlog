class AddWordToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :word, :string
  end
end
