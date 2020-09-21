class PhotosController < ApplicationController

  include HTTParty

  def index
    config.cache_store = :memory_store, { size: 16.megabytes }
    config.session_store = :cache_store
    url = request.fullpath
    uri  = URI.parse(url)
    keywords = params['words'] ? params['words'].split("|") : []
    @words_array = keywords
    # puts "DEBUG>>> WORDS ARRAY: #{@words_array} "
    @comment = Comment.new
    @comments = Comment.all

    @selected = params['selected'].to_i || 1
    puts "DEBUG>>>> SELECTED = " + @selected.to_s

    getPhotos #redirects if no @words_array is found

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
      end

      keywords = params['words'] ? params['words'].split("|") : []

      session[:photourltest] = @photourl
      puts "SESSION 1 >>>>>> #{session[:photourltest]}"

      redirect_to(home_url + "?selected=1&words="+@words_string)
      # TODO: refractoring: questo redirect non e' bene che sia qui.
    else
      puts "DEBUG>>> PHOTO ARRAY: #{@words_array}"
      @photo_url_index = @selected *40

      for i in 0..2
        word = @words_array[i]
        @words_string += "#{word}"
        if i < 2
          @words_string += "|"
        end
      end
      @photourl = session[:photourltest]
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
    if photo["total_results"] >= 45
      k=0
      while k < 40
        @photourl.push(photo["photos"][k]["src"]["medium"])
        k += 1
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
