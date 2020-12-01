class CreateWordsFromComments < ActiveRecord::Migration[6.0]
  def change

    Comment.all.each do |c|
      if c.associated_word
        unless c.word_id
          word = Word.find_by(:value => c.associated_word)
          puts "word #{word.value} already present with id #{word.id}" if word
          unless word
            puts "word #{c.associated_word} not found"
            word = Word.new
            response = word.search_photos(c.associated_word)
            puts "created Word #{word.value} with id = #{word.id}" if response
          end
          # c.word = word
          c.update(word: word) if response
          c.save!
        end
      end
      puts "c.word_id set to #{c.word_id}"
    end

  end
end
