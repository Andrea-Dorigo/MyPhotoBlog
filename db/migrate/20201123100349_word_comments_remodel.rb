class WordCommentsRemodel < ActiveRecord::Migration[6.0]
  def change

    rename_column :comments, :word, :associated_word

    Comment.reset_column_information

    create_table :words do |t|
      t.string :value
      t.timestamp :generated_at

      t.timestamps
    end
    create_table :pictures do |t|
      t.integer :width
      t.integer :height
      t.string :url

      t.timestamps
    end

    add_reference :pictures, :word, null: false, foreign_key: true
    add_reference :comments, :word, foreign_key: true

    # comments = Comment.all
    # words = Word.all
    # comments.each do |c|
    #   search_photos(c.associated_word) if words.length == 0
    #   puts "associated_word: #{c.associated_word}"
    #   if c.associated_word
    #     words.each do |w|
    #       puts "value: #{w.value}"
    #       if w.value != c.associated_word
    #         puts "searching for #{c.associated_word}"
    #         search_photos(c.associated_word)
    #       end
    #     end
    #   end
    # end

  end

end
