class PhotosController < ApplicationController

  def index
    load_data # @words_array, @selected, @comment, @comments, @photourl
    if @words_array.empty?
      3.times { @words_array.push(Word.search_word) }
      redirect_to(home_url + "?s=1&w=#{serialize_words(@words_array)}")
    else
      @words_array.each do |word|
        word.pictures.each { |p| @photourl.push(p.url) }
      end
    end
  end

  def show_photo_gallery

    respond_to do |format|
      load_data
      if @words_array.empty? #refresh button
        3.times { @words_array.push(Word.search_word) }
      end
      @words_string = serialize_words(@words_array)
       format.js {
         @words_array.each do |word|
           word.pictures.each { |p| @photourl.push(p.url) }
         end
       }
       format.html {
         unless params[:w].nil?
           redirect_to(home_url + "?s=#{params[:s]}&w=#{@words_string}")
         else
           redirect_to(home_url)
         end
       }
    end
  end

  def create_comment
    load_data
    word = Word.find_by(:value => params[:comment][:associated_word])
    @comment = word.comments.new(params.require(:comment).permit(:name, :email, :body, :associated_word))
    words_string = serialize_words(@words_array)
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

  def load_data
    require 'open-uri'
    uri  = URI.parse(request.fullpath)
    @words_array = []
    # @words_array = params[:w] ? params[:w].split("|") : []
    if params[:w]
      splitted = params[:w].split("|")
      splitted.each do |w|
        found = Word.find_by(:value => "#{w}")
        @words_array.push(found)
      end
    end
    @selected = params[:s].to_i || 1
    @comment = Comment.new
    @comments = Comment.all.order("created_at DESC")
    @comment.name = cookies[:name]
    @comment.email = cookies[:email]
    @photourl = []
      logger.debug "load data words_array: #{@words_array} params #{params[:w]} uri = #{uri}"
  end

  private def serialize_words(words_array)
    return "#{@words_array[0].value}|#{@words_array[1].value}|#{@words_array[2].value}"
  end

end #PhotosController
