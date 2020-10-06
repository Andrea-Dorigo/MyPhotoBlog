class PhotosController < ApplicationController

  include HTTParty

  def index
    session_key = cookies[:_myphotoblog_session]
    load_data # @words_array, @selected, @comment, @comments
    if @words_array.empty?
      get_photourl()
      redirect_to(home_url + "?selected=1&words=#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}")
    else
      @photourl = Rails.cache.fetch("photourl_#{session_key}", expires_in: 5.minutes) do
        photourl = get_photourl(@words_array)
      end
    end
  end

  def show_photos_js
    respond_to do |format|
       format.js {
         session_key = cookies[:_myphotoblog_session]
         @words_array = params['words'] ? params['words'].split("|") : []
         @photourl = Rails.cache.fetch("photourl_#{session_key}", expires_in: 5.minutes) do
           get_photourl(@words_array)
         end
         @selected = params['selected'].to_i || 1
       }
       format.html {
         @words_array = params['words'] ? params['words'].split("|") : []
         redirect_to(home_url + "?selected=#{params[:selected]}&words=#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}")
       }
    end
  end

  def create_comment
    session_key = cookies[:_myphotoblog_session]
    @comment = Comment.new(params.require(:comment).permit(:name, :email, :body))
    uri  = URI.parse(request.fullpath)
    @words_array = params['words'] ? params['words'].split("|") : []
    saved = @comment.save
    @comments = Comment.all
    @selected = params['selected'].to_i || 1
    @photourl = Rails.cache.fetch("photourl_#{session_key}", expires_in: 5.minutes) do
      get_photourl(@words_array)
    end
    if saved
      cookies[:name] = @comment.name
      cookies[:email] = @comment.email
      @comment = Comment.new
    end
    render 'index'
  end

  # Returns an array containing the photo urls of a given words_array of size 3;
  # If words_array is empty, it populates it with 3 new words
  def get_photourl(words_array)
    unless words_array.empty?
      photourl = []
      words_array.each do |word|
        photo = fetch_photo_urls(word)
        40.times do |k|
          photourl.push(photo["photos"][k]["src"]["medium"])
        end
      end
    else
      doc = HTTParty.get("https://www.randomlists.com/data/words.json")
      parsed = JSON.parse(doc.to_s)
      i = 0
      while i < 3
        word = parsed["data"].sample
        logger.debug "searching for: #{word}"
        photo = fetch_photo_urls(word)
        if photo["total_results"] >= 40
          40.times do |k|
            @photourl.push(photo["photos"][k]["src"]["medium"])
          end
          @words_array.push(word)
          i += 1
        end
      end
      Rails.cache.write("photourl_#{session_key}", @photourl, expires_in: 5.minutes)
    end
    photourl
  end

  # Fetches photo data of a given word, using the pexels api
  def fetch_photo_urls(word)
    url = "https://api.pexels.com/v1/search?query=#{word}&per_page=40"
    pexels_key = ENV.fetch('PEXELS_API_KEY')
    response = Excon.get(url, headers: {'Authorization' => pexels_key } )
    return nil if response.status != 200
    JSON.parse(response.body)
  end

  # Initializes and loads the variables necessary to the views, precisely:
  # @words_array, @selected, @comment, @comments
  def load_data
    require 'open-uri'
    uri  = URI.parse(request.fullpath)
    @words_array = params['words'] ? params['words'].split("|") : []
    @selected = params['selected'].to_i || 1
    @comment = Comment.new
    @comments = Comment.all
    @comment.name = cookies[:name]
    @comment.email = cookies[:email]
  end

end #PhotosController
