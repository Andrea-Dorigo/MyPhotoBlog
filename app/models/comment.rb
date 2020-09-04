class Comment < ApplicationRecord

  validates  :name, :email, :body, presence: true



  # def funny_name
  #
  # end
end
