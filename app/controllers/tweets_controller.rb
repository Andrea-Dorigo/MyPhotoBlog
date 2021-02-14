class TweetsController < ApplicationController

   def index
     @tweets = Tweet.all
   end

   def show
     @tweet = Tweet.find(params[:id])
   end

   def new
     @tweet = Tweet.new
   end

   def create
     @tweet = Tweet.new(tweet_params)

     if @tweet.save
       redirect_to :action => 'index'
     else
       render :action => 'new'
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
