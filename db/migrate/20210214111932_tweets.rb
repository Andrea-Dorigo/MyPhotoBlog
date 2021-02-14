class Tweets < ActiveRecord::Migration[6.0]
  def change
    create_table :tweets do |t|
      t.string :body

      t.timestamps
    end
  end
end
