class CommentsController < ApplicationController

  def show
    # check if the @ is necessary
    @comment = Comment.find(params[:id])
  end



  def create

    @comment = Comment.new(comment_params)
    # render plain: params[:comment].inspect
    @comment.save!
    # @word = "another"
    redirect_to home_url
  end

  private def comment_params

    params.require(:comment).permit(:name, :email, :body)

  end
  private def word_param

    params.require(:word).permit(:value)

  end

end
