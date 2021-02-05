class Comment < ApplicationRecord

  belongs_to :word

  validates :name, :body, :associated_word, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }


end
