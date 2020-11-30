class Comment < ApplicationRecord

  belongs_to :word

  validates :name, :body, :word, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }

  def create_comment
    load_data
    @comment = Comment.new(params.require(:comment).permit(:name, :email, :body, :word))
    words_string = params[:w]
    saved = @comment.save
    if saved
      cookies[:name] = @comment.name
      cookies[:email] = @comment.email
    end
    respond_to do |format|
      format.js {
        render partial: "append_comment", locals: {comment: @comment, comments: @comments }
      }
      format.html {
        @comment.body = "" if saved
        redirect_to(home_url + "?s=#{params[:s]}&w=#{words_string}")
      }
    end
  end

end
