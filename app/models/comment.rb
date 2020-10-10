class Comment < ApplicationRecord

  validates  :name, :body, presence: true
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}


  # def funny_name
  #
  # end
end
