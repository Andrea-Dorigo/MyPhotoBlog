class PhotosController < ApplicationController

  include HTTParty

  def index
    load_data # @words_array, @selected, @comment, @comments, @photourl
    logger.debug "words array === #{@words_array.to_s}"
    if @words_array.empty?
      @photourl = get_photourl(@words_array)
      redirect_to(home_url + "?selected=1&words=#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}")
    else
      words_string = "#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}"
      @photourl = Rails.cache.fetch("photourl_#{words_string}", expires_in: 60.minutes) do
        photourl = get_photourl(@words_array)
      end
    end
end

  def show_photos_js
    respond_to do |format|
      @words_array = params['words'] ? params['words'].split("|") : []
      @photourl = []
      if @words_array==[]
        Rails.cache.clear
      end
       format.js {
        words_string = "#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}"
         @photourl = Rails.cache.fetch("photourl_#{words_string}", expires_in: 60.minutes) do
           get_photourl(@words_array)
         end
         @selected = params['selected'].to_i || 1
       }
       format.html {
         unless params["words"].nil?
           redirect_to(home_url + "?selected=#{params[:selected]}&words=#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}")
         else
           redirect_to(home_url)
         end
       }
    end
  end

  def create_comment
    load_data
    @comment = Comment.new(params.require(:comment).permit(:name, :email, :body))
    words_string = "#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}"
    @photourl = Rails.cache.fetch("photourl_#{words_string}", expires_in: 60.minutes) do
      get_photourl(@words_array)
    end
    saved = @comment.save
    if saved
      cookies[:name] = @comment.name
      cookies[:email] = @comment.email
    end
    respond_to do |format|
      format.js {
        render partial: "append_comment", locals: {comment: @comment}
      }
      format.html {
        if saved
          @comment.body = ""
        end
          render 'index', locals: {comment: @comment}
      }
    end
  end

  # Returns an array containing the photo urls of a given words_array of size 3;
  # If words_array is empty, it populates @words_array with 3 new words
  def get_photourl(words_array)
    photourl = []
    unless words_array.empty?
      words_array.each do |word|
        photo = fetch_photo_urls(word)
        40.times do |k|
          photourl.push(photo["photos"][k]["src"]["medium"])
        end
      end
    else
      @words_array = []
      doc = HTTParty.get("https://www.randomlists.com/data/words.json")
      parsed = JSON.parse(doc.to_s)
      i = 0
      while i < 3
        word = parsed["data"].sample
        logger.debug "searching for: #{word}"
        photo = fetch_photo_urls(word)
        if photo["total_results"] >= 40
          40.times do |k|
            photourl.push(photo["photos"][k]["src"]["medium"])
          end
          @words_array.push(word)
          i += 1
        end
      end
      words_string = "#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}"
      Rails.cache.write("photourl_#{words_string}", photourl, expires_in: 60.minutes)
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
  # @words_array, @selected, @comment, @comments, @photourl
  def load_data
    require 'open-uri'
    uri  = URI.parse(request.fullpath)
    @words_array = params['words'] ? params['words'].split("|") : []
    @selected = params['selected'].to_i || 1
    @comment = Comment.new
    @comments = Comment.all
    @comment.name = cookies[:name]
    @comment.email = cookies[:email]
    @photourl = []
  end

end #PhotosController
