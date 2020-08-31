class PhotosController < ApplicationController

  include HTTParty
  def index

    puts "params words array = " + params[:words_array].to_s
    @words_array = params[:words_array] || []

    puts "words_array after params = " + @words_array.to_s


if @words_array == []
    require 'open-uri'
    url = "https://www.randomlists.com/data/words.json"
    doc = HTTParty.get(url)
    parsed = JSON.parse(doc.to_s) # returns a hash
    for i in 0..2
        word = parsed["data"].sample
        @words_array.push(word)
    end

end
    # @words_array = params[:words_array]
    puts "words array final " + @words_array.to_s
    #TODO: is @ necessary?
    @word = params[:word] || "empty"
    @comments = Comment.all
  end

  # def show
  #   @comment = Comment.find(params[:id])
  # end
  def getwords

    require 'open-uri'
    url = "https://www.randomlists.com/data/words.json"
    doc = HTTParty.get(url)
    parsed = JSON.parse(doc.to_s) # returns a hash
    @photourl = []
    #TODO: si potrebbe aggiungere il controllo per evitare duplicati, pur restando un'evenienza molto rara
    i = 0
    k = 0
    # TODO: migliorare entrambi i cicli, renderli piu' efficienti e piu' comprensiili
    while i < 3
      # @words_array.push(parsed["data"].sample)
      # puts i.to_s
      word = parsed["data"].sample
      # puts  "i = " + i.to_s + " " + @words_array[i]

      #TODO spostare fuori in una funzione meglio definita
      @photo = find_photo(word)
      # puts @photo["total_results"].to_s
      if @photo["total_results"] < 40
        # puts "not enough results for: " + word.to_s
      else
        k=0;
        while k < 40
          # puts @photo["photos"][k]["src"]["medium"].to_s
          @photourl.push(@photo["photos"][k]["src"]["medium"])
          # puts @photourl.length.to_s
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
    # TODO: use pexels ruby methods
    request_api("https://api.pexels.com/v1/search?query=" + query + "&per_page=40")
  end

end
