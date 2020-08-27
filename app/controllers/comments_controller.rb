class CommentsController < ApplicationController

  def create

    @comment = Comment.new(comment_params)
    render plain: params[:comment].inspect

  end

  private def comment_params

    params.require(:comment).permit(:name, :email, :body)

  end

end
