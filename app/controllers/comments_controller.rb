class CommentsController < ApplicationController

  # def show
  #   # check if the @ is necessary
  #   comment = Comment.find(params[:id])
  # end

  def create
    begin
      comment = Comment.new(comment_params)
      # render plain: params[:comment].inspect
      comment.save!
      cookies[:name] = comment.name;
      cookies[:email] = comment.email;
    rescue
      puts "rescued"
      #TODO: should pass with a parameter instead of hardcoding a string
      #TESTING
      redirect_to home_url + "?error=invalidpost", data: { no_turbolink: true } and return
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
