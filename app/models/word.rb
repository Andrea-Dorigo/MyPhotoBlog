class Word < ApplicationRecord

  has_many :comments
  has_many :pictures

  include HTTParty

  PHOTO_MIN_RESULTS = 40 # minimum ammount of results necessary per word

  # si potrebbe utilizzare il new con una validazione che controlla se ci sono almeno 40 foto con un before_save
  def self.search_word
    doc = HTTParty.get("https://www.randomlists.com/data/words.json")
    parsed = JSON.parse(doc.to_s)
    word = Word.new
    while word.value.nil?
      random_word = "#{parsed["data"].sample}"
      found = Word.find_by(:value => random_word)
      return found if found
      word.search_photos(random_word)
    end
    return word
  end

  def search_photos(random_word)
       url = "https://api.pexels.com/v1/search?query=#{random_word}&per_page=#{PHOTO_MIN_RESULTS}"
       pexels_key = ENV.fetch('PEXELS_API_KEY')
       response = Excon.get(url, headers: {'Authorization' => pexels_key } )
       photo = JSON.parse(response.body)
       return nil unless photo["total_results"]
       if photo["total_results"] >= PHOTO_MIN_RESULTS
         self.update(value: random_word, generated_at: Time.now)
         self.save!
         PHOTO_MIN_RESULTS.times do |k|
           picture = photo["photos"][k]
           self.pictures.create( url: picture["src"]["large2x"],
                                 width: picture["width"],
                                 height: picture["height"] )
         end
       end
  end

end
