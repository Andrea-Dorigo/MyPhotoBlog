class CommentsController < ApplicationController

  # def show
  #   # check if the @ is necessary
  #   comment = Comment.find(params[:id])
  # end

  def create
    begin
      comment = Comment.new(comment_params)
      comment.save!
      if params[:remember_me]
        cookies[:name] = comment.name;
        cookies[:email] = comment.email;
      end
    rescue
      #TODO: should pass with a parameter instead of hardcoding a string
      #TESTING
      redirect_to home_url + "?error=invalidpost#add_comment_form", data: { no_turbolink: true } and return
    end
    redirect_to home_url, data: { no_turbolink: true } and return
  end

  private def comment_params

    params.require(:comment).permit(:name, :email, :body)

  end
  private def word_param

    params.require(:word).permit(:value)

  end

end
