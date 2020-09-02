class PhotosController < ApplicationController

  include HTTParty

  def index

    #change how the words_array is passed (string split parsing)
    @words_array = params[:words_array] || []

    getPhotos
    #TODO: is @ necessary?
    @word = params[:word] || 1
    @comments = Comment.all
    puts @word
  end

  # def show
  #   @comment = Comment.find(params[:id])
  # end
  def getPhotos
    require 'open-uri'

    @photourl = []
    @photo_url_index = 0 * @word.to_f
    puts @photo_url_index.to_s
    #TODO: si potrebbe aggiungere il controllo per evitare duplicati, pur restando un'evenienza molto rara
    i = 0
    k = 0
    # TODO: migliorare entrambi i cicli, renderli piu' efficienti e piu' comprensiili
    # TODO: si potrebbe fare in modo che l'array degli url delle foto sia passato al click di una word
    if @words_array == []

      puts "empty words array"
      url = "https://www.randomlists.com/data/words.json"
      doc = HTTParty.get(url)
      parsed = JSON.parse(doc.to_s) # returns a hash

      while i < 3
        word = parsed["data"].sample
        # if search_photos(word)
          @words_array.push(word)
          i += 1
        # end
      end
    else
      for i in 0..2
        word = @words_array[i]
        # search_photos(word)
      end
      # @photo_url_index = 80
    end
      # @words_array.push(parsed["data"].sample)
      # puts i.to_s


      # puts  "i = " + i.to_s + " " + @words_array[i]

      #TODO spostare fuori in una funzione meglio definita


      puts "words array = " + @words_array.to_s

      # puts @photo.to_s
    end
    # puts "here"

  # def search(querystring)
  #   @photo = find_photo(querystring)
  #   @photourl = @photo["photos"].first["src"]["medium"]
  #
  # end


  def search_photos(word)
    # TODO: use pexels ruby methods
    photo = request_api("https://api.pexels.com/v1/search?query=" + word + "&per_page=40")

    if photo["total_results"] >= 40
      k=0;
      while k < 40
        # puts @photo["photos"][k]["src"]["medium"].to_s
        @photourl.push(photo["photos"][k]["src"]["medium"])
        # puts @photourl.length.to_s
        k += 1
      end
      response = true
    else
      response = false
    end
  end

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

end
