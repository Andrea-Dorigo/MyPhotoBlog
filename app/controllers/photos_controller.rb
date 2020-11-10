class PhotosController < ApplicationController

  include HTTParty

  PHOTO_MIN_RESULTS = 40 # minimum ammount of results necessary per word
  CACHE_EXPIRE_TIME = (ENV.fetch('CACHE_EXPIRE_TIME')).to_i.minutes

  def index
    load_data # @words_array, @selected, @comment, @comments, @photourl
    logger.debug "words array === #{@words_array}"
    if @words_array.empty?
      @words_array = get_words()
      redirect_to(home_url + "?s=1&w=#{serialize_words(@words_array)}")
    else
      @words_array.each do |word|
        @photourl.push(get_photos(word))
      end
      @photourl = @photourl.flatten
    end
  end

  def show_photo_gallery
    respond_to do |format|
      @words_array = params[:w] ? params[:w].split("|") : []
      @words_array = get_words() if @words_array.empty?
      @comments = Comment.all.order("created_at DESC")
      @photourl = []

      @selected = params[:s].to_i


      @words_string = serialize_words(@words_array)
       format.js {
         @words_array.each do |word|
           @photourl.push(get_photos(word))
         end
         @photourl = @photourl.flatten
         @selected = params[:s].to_i || 1
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
    @comments = Comment.all.order("created_at DESC")
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

  def get_photos(word)
    Rails.cache.fetch("photos_of_#{word}", expires_in: CACHE_EXPIRE_TIME) do
      photos = search_photos(word)
      photo_array = []
      40.times do |k|
        photo_array.push(photos[k])
      end
      photo_array
    end
  end

  def get_words
    words_array = []
    doc = HTTParty.get("https://www.randomlists.com/data/words.json")
    parsed = JSON.parse(doc.to_s)
    i = 0
    while i < 3
      word = parsed["data"].sample
      if search_photos(word) != []
           i += 1
           words_array.push(word)
      end
    end
    return words_array
  end

  def search_photos(word)
    photos_of = Rails.cache.fetch("photos_of_#{word}", expires_in: CACHE_EXPIRE_TIME) do
      logger.debug "photos_of_#{word} not found in cache"
       url = "https://api.pexels.com/v1/search?query=#{word}&per_page=40"
       pexels_key = ENV.fetch('PEXELS_API_KEY')
       response = Excon.get(url, headers: {'Authorization' => pexels_key } )
       return nil if response.status != 200
       photo = JSON.parse(response.body)
       photos_of_word = []
       if photo["total_results"] >= 40
        logger.debug "we have more than 40 results!"
         40.times do |k|
           photos_of_word.push(photo["photos"][k]["src"]["large2x"])
         end
         Rails.cache.write("photos_of_#{word}", photos_of_word, expires_in: CACHE_EXPIRE_TIME)
       end
       photos_of_word
    end
  end

  def load_data
    require 'open-uri'
    uri  = URI.parse(request.fullpath)
    @words_array = params[:w] ? params[:w].split("|") : []
    @selected = params[:s].to_i || 1
    @comment = Comment.new
    @comments = Comment.all.order("created_at DESC")
    @comment.name = cookies[:name]
    @comment.email = cookies[:email]
    @photourl = []
  end

  private def serialize_words(words_array)
    return "#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}"
  end

end #PhotosController
