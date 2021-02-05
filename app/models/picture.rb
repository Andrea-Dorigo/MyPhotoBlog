class Picture < ApplicationRecord

  belongs_to :word

  validates :url, presence: true#, uniqueness: true

end
