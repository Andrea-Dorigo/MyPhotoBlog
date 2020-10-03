class PhotosController < ApplicationController

  include HTTParty

  def index

    require 'open-uri'
    uri  = URI.parse(request.fullpath)
    words_array = params['words'] ? params['words'].split("|") : []
    @comment = Comment.new
    @comments = Comment.all

    puts "words array #{words_array}, selected = #{params[:selected].to_i}"
    if words_array == []
      photourl = []
      doc = HTTParty.get("https://www.randomlists.com/data/words.json")
      parsed = JSON.parse(doc.to_s)
      i = 0
      while i < 3
        word = parsed["data"].sample
        puts "searching for #{word}"
        photo = request_api("https://api.pexels.com/v1/search?query=#{word}&per_page=40")
        if photo["total_results"] >= 40
          k=0
          while k < 40
            photourl.push(photo["photos"][k]["src"]["medium"])
            k += 1
          end
          words_array.push(word)
          i += 1
        end
      end
      session[:photourl] = photourl
      session[:words_array] = words_array
      redirect_to(home_url + "?selected=1&words=#{words_array[0]}|#{words_array[1]}|#{words_array[2]}")
    end
  end

  def request_api(url)
    pexels_key = ENV.fetch('PEXELS_API_KEY')
    response = Excon.get(url, headers: {'Authorization' => pexels_key } )
    return nil if response.status != 200
    JSON.parse(response.body)
  end

  def show_photos_js
    respond_to do |format|
       format.js 
       format.html {
         words_array = session[:words_array]
         redirect_to(home_url + "?selected=#{params[:selected]}&words=#{words_array[0]}|#{words_array[1]}|#{words_array[2]}")
       }
    end
  end

  def create_comment
    @comment = Comment.new(params.require(:comment).permit(:name, :email, :body))
    uri  = URI.parse(request.fullpath)
    @words_array = params['words'] ? params['words'].split("|") : []
    # ATTENZIONE: ORA QUANDO COMMENTI L'IMMAGINE SELEZIONATA TORNA QUELLA DI PARTENZA (fa il render di index questo metodo!)
    saved = @comment.save
    @comments = Comment.all
    @selected = params['selected'].to_i || 1
    getPhotos

    if saved
      puts "DEBUG>>> COMMENTO SALVATO"
      session[:name] = @comment.name
      session[:email] = @comment.email
      @comment = Comment.new
    end
    render 'index'
  end
end
