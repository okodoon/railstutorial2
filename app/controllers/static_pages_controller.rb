class StaticPagesController < ApplicationController
	protect_from_forgery with: :exception
  def home
    if logged_in?
  	 @micropost = current_user.microposts.build
     @feed_items = current_user.feed.paginate(page: params[:page])
   end
  end

  def help
  end

  def about
  end

  def contact 
  end

end
