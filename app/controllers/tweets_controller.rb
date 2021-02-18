class TweetsController < ApplicationController



   def index
     @tweets = Tweet.all
   end

   def show
     puts "SHOW"
   end

   def new
     puts "NEW"
     @tweet = Tweet.new
   end

   def create
     puts "CREATE"
     @tweet = Tweet.new(tweet_params)

     respond_to do |format|
       if @tweet.save
         format.html {  }
         format.json { render :show, status: :created, location: @tweet }
       else
         # format.turbo_stream { render turbo_stream: turbo_stream.replace(@tweet, partial: "tweets/form", locals: { tweet: @tweet}) }
         # format.html { render :new }
         format.json { render json: @tweet.errors, status: :unprocessable_entity }
       end
     end
   end
   def edit
   end

   def update
   end

   def delete
     Tweet.find(params[:id]).destroy
     redirect_to action => 'index'
   end


   def tweet_params
     params.permit(:body)
   end
end
