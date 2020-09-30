class PhotosController < ApplicationController

  include HTTParty

  def index
    # config.cache_store = :memory_store, { size: 16.megabytes }
    # config.session_store = :cache_store

    uri  = URI.parse(request.fullpath)
    keywords = params['words'] ? params['words'].split("|") : []
    @words_array = keywords
    puts "DEBUG>>> WORDS ARRAY: #{@words_array} "
    @comment = Comment.new
    @comments = Comment.all

    @selected = params['selected'].to_i || 1

    require 'open-uri'
    @photourl = []
    @photo_url_index = 40 * @selected
    @words_string = ""
    if @words_array == []
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
      # keywords = params['words'] ? params['words'].split("|") : []
      session[:photourltest] = @photourl
      session[:words_array] = @words_array
      session[:selected] = @selected
      redirect_to(home_url + "?selected=1&words="+@words_string)
    else
      # puts "DEBUG>>> PHOTO ARRAY: #{@words_array}"
      for i in 0..2
        word = @words_array[i]
        @words_string += "#{word}"
        if i < 2
          @words_string += "|"
        end
      end
      @photourl = session[:photourltest]
      session[:selected] = @selected
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
      session[:name] = @comment.name
      session[:email] = @comment.email
      @comment = Comment.new
    else
      @comment.errors.messages.keys.each do |c|
        puts "DEBUG>>> ERRORE NEL SALVATAGGIO = #{c}"
      end
    end
    render 'index', locals: {words_array: @words_array}
  end

  def search_photos(word)

      # @photourl = []
    puts "CALLING API FOR: #{word}"
    # TODO: use pexels ruby methods
    photo = request_api("https://api.pexels.com/v1/search?query=#{word}&per_page=40")
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

  def show_photos_js
    @photourl = session[:photourltest]
    @words_array = session[:words_array]
    @selected = params['selected'].to_i || session[:selected] #TODO: questo probabilmente si puo' passare al click
    puts "deb #{@selected}"
    puts "debugggg #{params['selected']}"
    # puts "DEBUGGG photourl = #{@photourl}, words_array = #{@words_array}, selected = #{@selected}"
    @photo_url_index = 40 * @selected
    @words_string = ""
    for i in 0..2
      word = @words_array[i]
      @words_string += "#{word}"
      if i < 2
        @words_string += "|"
      end
    end

    # @photourl = []

    # uri  = URI.parse(request.fullpath) #errore! l'url ora e' localhost/show_photos_js e non contiene i parametri.
    # keywords = params['words'] ? params['words'].split("|") : []
    # @words_array = keywords
    # @words_string = ""
    # puts "DEBUG>>> WORDS ARRAY: #{uri} "
    # for i in 0..2
    #   word = @words_array[i]
    #   @words_string += "#{word}"
    #   if i < 2
    #     @words_string += "|"
    #   end
    # end
    # @selected = params['selected'].to_i || 1
    # @photo_url_index = 40 * @selected
    #
    #   search_photos("dog")

    # puts "AJAX_CALL>>> photo url: #{@photourl}"
    respond_to do |format|
       format.js
    end
  end
end
