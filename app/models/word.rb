class Word < ApplicationRecord

  include HTTParty

  PHOTO_MIN_RESULTS = 40 # minimum ammount of results necessary per word

  has_many :comments
  has_many :pictures, dependent: :destroy
  accepts_nested_attributes_for :pictures

  before_validation :fetch_remote_photos_on_create, on: :create

  validates :value, presence: true, uniqueness: true
  validates :pictures, presence: true
  validate :pictures_count

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

  # self.bootstrap(word)
  #   w = Word.new(.....)
  #   fetch_remote_photos_on_create
  #   save!
  # end

  # def initialize_with_photos(word)
  #   params = {word: word}
  #   # get photos
  #   params[:photos] = photos
  # end

  # def initialize_with_photos!(word)
  #   initialize_with_photos(word)
  #   self.save!
  # end

private

  def fetch_remote_photos_on_create
    url = "https://api.pexels.com/v1/search?query=#{self.value}&per_page=#{PHOTO_MIN_RESULTS}"
    pexels_key = ENV.fetch('PEXELS_API_KEY')
    response = Excon.get(url, headers: {'Authorization' => pexels_key } )
    photos = JSON.parse(response.body)
    photos["photos"].each do |picture|
      self.pictures.build( url: picture["src"]["large2x"],
                            width: picture["width"],
                            height: picture["height"] )
    end
  end

  def pictures_count
    unless self.pictures.size >= PHOTO_MIN_RESULTS
      errors.add(:pictures, "should be at least #{PHOTO_MIN_RESULTS}")
    end
  end

end

