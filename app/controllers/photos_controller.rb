class PhotosController < ApplicationController

  def index
    Rails.logger.debug "DEBUG \n DEBUG >>> RELOADED \nDEBUG "
    load_data # @words_array, @selected, @comment, @comments, @photourl
    if @words_array.empty?
      3.times { @words_array.push(Word.search_word) }
      redirect_to(home_url + "?s=1&w=#{serialize_words(@words_array)}")
    else
      logger.debug "DEBUG >>> index > words_array #{@words_array}"
      @words_array.each do |word|
        word.pictures.each { |p| @photourl.push(p.url) }
      end
    end
  end

  def show_photo_gallery
    load_data
    if @words_array.empty? #refresh button
      3.times { @words_array.push(Word.search_word) }
    end
    @words_string = serialize_words(@words_array)
    puts "WORDS STRING CONTROLLER = #{@words_string}"
    respond_to do |format|
       format.turbo_stream {
         puts "TURBO STREAM"
           @words_array.each do |word|
             word.pictures.each { |p| @photourl.push(p.url) }
           end

         render "show_photo_gallery"
       }
       # format.js {
       #   @words_array.each do |word|
       #     word.pictures.each { |p| @photourl.push(p.url) }
       #   end
       # }
       format.html {
         puts "actually processed as HTML"
         @words_array.each do |word|
           word.pictures.each { |p| @photourl.push(p.url) }
         end
         # unless params[:w].nil?
         #   redirect_to(home_url + "show?s=#{params[:s]}&w=#{@words_string}")
         # else
         #   redirect_to(home_url)
         # end
         render "index"
       }
    end
  end

  def create_comment
    load_data
    word = Word.find_by(:value => params[:comment][:associated_word])
    @comment = word.comments.new(params.require(:comment).permit(:name, :email, :body, :associated_word))
    @words_string = serialize_words(@words_array)
    saved = @comment.save
    if saved
      cookies[:name] = @comment.name
      cookies[:email] = @comment.email
    end
    respond_to do |format|
      format.turbo_stream {
         puts "DEBUG>>> TURBO STREAM"
       }
      # format.js {
      #   render partial: "append_comment", locals: {comment: @comment, comments: @comments }
      # }
      format.html {
        logger.debug "DEBUG>>> CREATE COMMENT HTML RESPONSE"
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
    unless @words_array.empty? #refresh button
      @words_string = serialize_words(@words_array)
    end
    @photourl = []
    logger.debug "load data words_array: #{@words_array} params #{params[:w]} uri = #{uri}"
  end

  private def serialize_words(words_array)
    logger.debug "DEBUG >>> serialize_words > words_array = #{words_array}"
    return "#{words_array[0].value}|#{words_array[1].value}|#{words_array[2].value}"
  end

end #PhotosController
