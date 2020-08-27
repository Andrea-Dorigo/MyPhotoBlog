class CommentsController < ApplicationController

  def show

    @comment = Comment.find(params[:id])
  end



  def create

    @comment = Comment.new(comment_params)
    # render plain: params[:comment].inspect
    @comment.save
    redirect_to @comment
  end

  private def comment_params

    params.require(:comment).permit(:name, :email, :body)

  end

end
