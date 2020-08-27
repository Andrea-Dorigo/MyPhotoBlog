class PhotosController < ApplicationController

  include HTTParty
  def index
    getwords
    @comments = Comment.all
  end

  def show
    @comment = Comment.find(params[:id])
  end
  def getwords

    require 'open-uri'
    url = "https://www.randomlists.com/data/words.json"
    doc = HTTParty.get(url)
    parsed = JSON.parse(doc.to_s) # returns a hash
    @words_array = Array.new
    @photourl = Array.new
    #TODO: si potrebbe aggiungere il controllo per evitare duplicati, pur restando un'evenienza molto rara
    i = 0
    k = 0
    # TODO: migliorare entrambi i cicli, renderli piu' efficienti e piu' comprensiili
    while i < 3
      # @words_array.push(parsed["data"].sample)
      # puts i.to_s
      word = parsed["data"].sample
      puts word.to_s
      # puts  "i = " + i.to_s + " " + @words_array[i]

      #TODO spostare fuori in una funzione meglio definita
      @photo = find_photo(word)

      if @photo["total_results"] < 5

      else

        k=0;
        while k < 5
          @photourl.push(@photo["photos"][k]["src"]["medium"])
          k += 1
        end
        i += 1
        @words_array.push(word)
      end
      puts "words array = " + @words_array.to_s
      # puts @photo.to_s
    end
    # puts "here"
  end

  # def search(querystring)
  #   @photo = find_photo(querystring)
  #   @photourl = @photo["photos"].first["src"]["medium"]
  #
  # end

  def request_api(url)

    response = Excon.get(
      url,
      headers: {
        'Authorization' => ENV.fetch('PEXELS_API_KEY')
        # 'Authorization' => ENV["PEXELS_API_KEY"]
        # 'Authorization' => '563492ad6f917000010000012fdc3c81638f48b2a3a31e02d07b3f3c'
      }
    )
    return nil if response.status != 200
    JSON.parse(response.body)

  end

  def find_photo(query)
    request_api("https://api.pexels.com/v1/search?query=" + query)
  end

end
