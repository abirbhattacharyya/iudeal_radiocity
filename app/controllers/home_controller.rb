class HomeController < ApplicationController
  def index
    if logged_in?
      if current_user.profile.nil?
        render :template => "users/profile"
      elsif current_user.products.size <= 0
        render :template => "products/product_catalog"
      else
        @notifications = [["profile", current_user.profile.created_at], ["prices", current_user.products.last.created_at]]
        @notifications.sort!{|n1, n2| n2[1] <=> n1[1]}
        render :template => "home/notifications"
      end
    end
    @products = Product.all#(:include => :offers)
    offer_token = (session[:_csrf_token] ||= SecureRandom.base64(32))
    ip = request.remote_ip

    Offer.update_all(["response = ?","expired"],["ip = ? AND token = ? AND response in (?)",ip,offer_token,Product::RESPONSES])

  end

  def say_your_price
    if logged_in?
      redirect_to root_path
      return
    end
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end
    @today = Time.now.in_time_zone("Eastern Time (US & Canada)").to_datetime    
    @size = Product.count.to_i
    @per_page = 13
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    @products = Product.all(:limit => "#{@per_page*(@page - 1)}, #{@per_page}")
    @page_start_num = ((@page - 4) > 0) ? (@page - 4) : 1
    @page_end_num = ((@page_start_num + 8) > @post_pages) ? @post_pages : (@page_start_num + 8)
    @page_start_num = ((@post_pages - @page_end_num) < 8) ? (@page_end_num - 8) : @page_start_num if @post_pages >= 8
  end




  def reports
    @today = Time.now.in_time_zone("Eastern Time (US & Canada)").to_date
    @start_date = "2012-07-03".to_date

    @today_negotiations = Offer.find(:first,:select => ["SUM(counter) as total"],:conditions => ["created_at between ? AND ?",@today.beginning_of_day,@today.end_of_day] )
    @cumulative_negotiations = Offer.find(:first,:select => ["SUM(counter) as total"],:conditions => ["created_at between ? AND ?",@start_date.beginning_of_day,@today.end_of_day] )

    @today_sales =   Offer.sum(:price, :conditions => ["response = ? AND (created_at between ? AND ?)", "paid", @today.beginning_of_day,@today.end_of_day] ).to_i
    @cumulative_sales = Offer.sum(:price, :conditions => ["response = ? AND (created_at between ? AND ?)", "paid", @start_date.beginning_of_day,@today.end_of_day] ).to_i

    @today_total_sales =   Offer.count(:price, :conditions => ["response = ? AND (created_at between ? AND ?)", "paid", @today.beginning_of_day,@today.end_of_day] ).to_i
    @cumulative_total_sales = Offer.count(:price, :conditions => ["response = ? AND (created_at between ? AND ?)", "paid", @start_date.beginning_of_day,@today.end_of_day] ).to_i

  end


  def send_daily_report
    reports
    Notification.deliver_send_daily_report(@start_date,@today,@today_negotiations,@cumulative_negotiations,@today_sales,@cumulative_sales,@today_total_sales,@cumulative_total_sales)
    render :text => "Report sent"
  end

  private
   def validate_email(email)
     valid_email = true     
     if email.blank?
       valid_email= false       
     else
       unless email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/)
         valid_email = false       
       end
     end
     valid_email
   end
end
