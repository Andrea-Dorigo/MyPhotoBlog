class PhotosController < ApplicationController

  include HTTParty

  def index
    session_key = cookies[:_myphotoblog_session]
    require 'open-uri'
    uri  = URI.parse(request.fullpath)
    @words_array = params['words'] ? params['words'].split("|") : []
    @selected = params['selected'].to_i || 1
    @photourl = []
    @comment = Comment.new
    @comments = Comment.all
    @comment.name = cookies[:name]
    @comment.email = cookies[:email]

    puts "words array #{@words_array}, selected = #{params[:selected].to_i}"

    if @words_array == []
      doc = HTTParty.get("https://www.randomlists.com/data/words.json")
      parsed = JSON.parse(doc.to_s)
      i = 0
      while i < 3
        word = parsed["data"].sample
        puts "searching for: #{word}"
        photo = request_api("https://api.pexels.com/v1/search?query=#{word}&per_page=40")
        if photo["total_results"] >= 40
          k=0
          while k < 40
            @photourl.push(photo["photos"][k]["src"]["medium"])
            k += 1
          end
          @words_array.push(word)
          i += 1
        end
      end
      Rails.cache.write("photourl_#{session_key}", @photourl, expires_in: 5.minutes)
      redirect_to(home_url + "?selected=1&words=#{@words_array[0]}|#{@words_array[1]}|#{@words_array[2]}")
    else
      @photourl = get_photourl(@words_array)
      Rails.cache.fetch("photourl_#{session_key}", expires_in: 5.minutes) do
        @photourl
      end
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
      puts "DEBUG>>> COMMENTO SALVATO"
      cookies[:name] = @comment.name
      cookies[:email] = @comment.email
      @comment = Comment.new
    end
    render 'index'
  end


  def get_photourl(words_array)
    photourl = []
    words_array.each do |word|
      photo = request_api("https://api.pexels.com/v1/search?query=#{word}&per_page=40")
      k=0
      while k < 40
        photourl.push(photo["photos"][k]["src"]["medium"])
        k += 1
      end
    end
    photourl
  end
end
