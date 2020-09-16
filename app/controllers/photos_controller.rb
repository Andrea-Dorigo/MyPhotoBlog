class PhotosController < ApplicationController

  include HTTParty

  def index

    url = request.fullpath
    uri  = URI.parse(url)
    keywords = params['words'] ? params['words'].split("|") : []
    @words_array = keywords
    # puts "DEBUG>>> WORDS ARRAY: #{@words_array} "
    @comment = Comment.new
    @comments = Comment.all

    @selected = params['selected'].to_i || 1
    puts "DEBUG>>>> SELECTED = " + @selected.to_s

    getPhotos

    #TODO: is @ necessary?
  end

  def getPhotos
    require 'open-uri'
    @photourl = []
    @photo_url_index = 0 * @selected
    #TODO: si potrebbe aggiungere il controllo per evitare duplicati, pur restando un'evenienza molto rara
    # TODO: migliorare entrambi i cicli, renderli piu' efficienti e piu' comprensiili
    # TODO: si potrebbe fare in modo che l'array degli url delle foto sia passato al click di una selected


    @words_string = ""
    if @words_array == []
      @photo_url_index = 40
      doc = HTTParty.get("https://www.randomlists.com/data/words.json")
      parsed = JSON.parse(doc.to_s)
      i = 0
      while i < 3
        word = parsed["data"].sample
        if search_photos(word)
          @words_array.push(word)
          @words_string += "#{word}"
          if i < 2
            @words_string += "|"
          end
          i += 1
        end

        # puts "PHOTOURL>>>     #{@photourl}"
        puts "DEBUG>>> CREATING PHOTO ARRAY: #{@words_array.to_s}"


      end





      # puts "DEBUG>>> REDIRECTING"

      # https://images.pexels.com/photos/3810754/pexels-photo-3810754.jpeg?auto=compress&cs=tinysrgb&h=350
      # https://images.pexels.com/photos/3178818/pexels-photo-3178818.jpeg?auto=compress&cs=tinysrgb&h=350

      keywords = params['words'] ? params['words'].split("|") : []

      # cookies[:photo_url_array] = nil
      # photourlarray = []
      # @photourl.each do |url|
      #   # puts "#{url}" + "\n"
      #   photo_id = url.split("/")
      #   photourlarray.push(photo_id[4])
      #   # teststring  += "#{@photourl[j]}" +"\n"
      # end
      #cookies[:photo_url_array] = photourlarray
      Rails.cache.fetch(:cached_urls, force: true, expires_in: 1.minutes) do
        puts "miss"
        @photourl
      end
      # puts "CACHED RESULTS 1 << #{cached_urls}"
      #session[:photosession] = photourlarray
      # session[:photo_url_array] = @photourl

      redirect_to(home_url + "?selected=1&words="+@words_string)
    else
      # @photo_url_index = @selected.to_i * 40
      puts "DEBUG>>> PHOTO ARRAY: #{@words_array}"
      @photo_url_index = @selected *40

      # @photourl = cookies[:photo_url_array]
      # puts "DEBUG PHOTOURL>>> #{@photourl}"
      #string = "#{cookies[:photo_url_array]}"
      #
      # puts "CACHED RESULTS 2 << #{cached_urls}"

      #puts "DEBUGGY SESSIONS >>>>>> #{:cached_result}"
      #splitted = string.split("&")
      #@photourl = []
      #splitted.each do |s|
      #  @photourl.push("https://images.pexels.com/photos/#{s}/pexels-photo-#{s}.jpeg?auto=compress&cs=tinysrgb&h=350")
      #end


      for i in 0..2
        word = @words_array[i]
        # search_photos(word)
        @words_string += "#{word}"
        if i < 2
          @words_string += "|"
        end
      end
      #TODO: rifare meglio!!!!! refractoring con search_photos
      @photourl2 = Rails.cache.fetch(:cached_urls) {
        @words_array.each do |w|
          search_photos(w)
        end
        return @photourl
      }
      puts "DEBUG>>> PHOTO URL #{@photourl2}"
      @photourl = @photourl2

    end
  end

  def create_comment

    @comment = Comment.new(params.require(:comment).permit(:name, :email, :body))
    url = request.fullpath
    uri  = URI.parse(url)
    keywords = params['words'] ? params['words'].split("|") : []
    @words_array = keywords
    saved = @comment.save
    @comments = Comment.all
    @selected = params['selected'].to_i || 1
    getPhotos

    if saved
      puts "DEBUG>>> COMMENTO SALVATO"
      cookies[:name] = @comment.name
      cookies[:email] = @comment.email
      @comment = Comment.new
    else
      @comment.errors.messages.keys.each do |c|
        puts "DEBUG>>> ERRORE NEL SALVATAGGIO = #{c}"
      end
    end
    render 'index', locals: {words_array: @words_array}
  end


  def search_photos(selected)
    puts "CALLING API"
    # TODO: use pexels ruby methods
    photo = request_api("https://api.pexels.com/v1/search?query=#{selected}&per_page=40")
    # puts "DEBUG>>> #{photo}"
    if photo["total_results"] >= 45
      k=0
      while k < 40
        # if photo["photos"][k]["src"]["medium"].include? "/pexels-photo-"
          @photourl.push(photo["photos"][k]["src"]["medium"])
          k += 1
        # end
      end
      response = true
    else
      response = false
    end
  end

  def request_api(url)
    #TODO: implement exception handling ?
    pexels_key = ENV.fetch('PEXELS_API_KEY')

    response = Excon.get(url, headers: {'Authorization' => pexels_key } )
    return nil if response.status != 200
    JSON.parse(response.body)
  end

end
