class ProductsController < ApplicationController
  before_filter :check_login, :except => [:capsule,:make_payment, :payments,:share_product,:book_room, :new_price, :send_to,:success,:cancel, :discount_price,:agreement,:confirm_agreement]

   def product_catalog
    if request.post?
      @product = Product.new(params[:product])
      @product.user = current_user
      @product.quantity = params[:product][:quantity].gsub(/\D+/, "") if params[:product][:quantity]
      @product.regular_price = params[:product][:regular_price].gsub(/\D+/, "")
      @product.target_price = params[:product][:target_price].gsub(/\D+/, "")
      if @product.save
        @product = nil
        flash[:notice] = "Product saved successfully"
        if params[:submit_button].strip.downcase.eql? "finish"
          redirect_to root_path
        end
      else
        flash[:error] = @product.errors.first[1]
      end
    end
  end

  # def book_room
  #   unless request.post?
  #     redirect_to root_path
  #     return
  #   end
  #   @product = Product.find_by_id(params[:id])
  #   offer_token = (session[:_csrf_token] ||= SecureRandom.base64(32))
  #   ip = request.remote_ip
  #   offer = @product.last_offer(ip,offer_token)
  #   @price =  offer.try(:price) || @product.regular_price
  #   render :layout => "book_room"
  # end

  def make_payment
     if request.post?
      
      @product = Product.find_by_id(params[:id])


      @today = Time.now.in_time_zone("Eastern Time (US & Canada)").to_datetime

      offer_token = (session[:_csrf_token] ||= SecureRandom.base64(32))
      ip = request.remote_ip
      @offer = @product.last_offer(ip,offer_token)
      unless @offer
        @offer = Offer.create(:product_id => @product.id,:price => @product.regular_price,:response => "counter", :token => offer_token, :ip => ip,:counter => 1)
      end
      
      if @offer.nil?
        redirect_to root_path
        return
      end
      session[@offer.id] = @offer.product.regular_price if session[@offer.id].nil?
      @month = Date.today.month
       @payment = Payment.find_or_initialize_by_offer_id(@offer.id)       
       @payment.price = @offer.price
       @payment.save(:validates => false)
       redirect_to payments_path(@payment)
    else
      redirect_to root_path
    end
  end

  def payments
    @payment = Payment.find(params[:id])
    @product = @payment.offer.product
    @month = Date.today.month
    @payment.cc_expiry_year = Date.today.year
    if @payment.nil?
      redirect_to root_path
      return
    end
    if request.post?
      @payment.attributes = params[:payment]
      @payment.cc_expiry_month = (@payment.cc_expiry_year == Date.today.year) ? @payment.cc_expiry_m1 : @payment.cc_expiry_m2
       
      @payment.price = (@payment.price)
      if @payment.valid? and @payment.validate_card
        success,msg = @payment.purchase(@payment.price)
        if success
          if Rails.env == "development"
            recipients = ADMINS
          else
            recipients = @payment.email
          end          
          # Notification.deliver_payment_mail_to_consumer(recipients, @payment)
          # Notification.deliver_payment_mail_to_merchant(ADMINS, @payment)
          flash[:notice] = "Payment saved."
          @payment.offer.update_attributes(:response => "paid")

          redirect_to success_path(@payment.id)
          return
            reset_session
            flash[:notice] = "Thank you for your purchase."
            redirect_to root_path
        else
            flash[:error] = "#{msg}"
        end
      else
        field_name = @payment.errors.first[0]
        flash[:error] = "Please enter valid #{field_name.to_s.titleize}"
      end

    end
  end

  def success
    @payment = Payment.find(params[:id])
    redirect_to root_path if @payment.nil?
  end


  def cancel
    flash[:notice] = "Payment has been canceled"
    redirect_to root_path
  end


  def capsule
    @product = Product.find_by_id(params[:id].to_i)
    redirect_to root_path and return if @product.nil?
    @today = Time.now.in_time_zone("Eastern Time (US & Canada)").to_datetime
    offer_token = (session[:_csrf_token] ||= SecureRandom.base64(32))
    ip = request.remote_ip
    
    if request.post?
      if params[:submit_button] == "no"
        last_offer = @product.last_offer(ip,offer_token)
        response =  Product::RESPONSES.shuffle.first
        if last_offer.nil?
          discount = (@product.regular_price * (rand(20) + 1)) / 100
          new_offer = @product.regular_price - discount
          if new_offer <= @product.target_price
            new_offer = @product.target_price
            response = "last"
          end
          if response == "share"
            new_offer = @product.regular_price
          end
          last_offer = Offer.create(:product_id => @product.id,:price => new_offer,:response => response,:token => offer_token, :ip => ip,:counter => 1)
        elsif last_offer.counter?
          discount = (last_offer.price * (rand(20) + 1)) / 100
          new_offer = last_offer.price - discount
          last_offer.response = response

          unless last_offer.share?
            if new_offer <= @product.target_price
              new_offer = @product.target_price
              last_offer.response = "last"
            end
            last_offer.counter += 1
            last_offer.price = new_offer
          end
          last_offer.save
        end
        if last_offer.counter?
          @message = "This is our new offer"
        elsif last_offer.last?
          @message = "This is our final offer"
        elsif last_offer.share?
        end
      end    
    end

    get_product_message
    flash[:notice] = @message
  end

  def share_product
    @product = Product.find(params[:id])
    offer_token = (session[:_csrf_token] ||= SecureRandom.base64(32))
    ip = request.remote_ip
     @today = Time.now.in_time_zone("Eastern Time (US & Canada)").to_datetime
    last_offer = @product.last_offer(ip,offer_token)
    discount = (last_offer.price * (rand(20) + 1)) / 100
    new_offer = last_offer.price - discount
    last_offer.response = "last"
    if new_offer <= @product.target_price
      new_offer = @product.target_price
    end
    last_offer.price = new_offer
    last_offer.save
    msg = "Hey, the best we can do is #{to_currency(last_offer.price, :precision => 2)} Deal?"
    get_product_message    
  end

  private

  def get_product_message
    offer_token = (session[:_csrf_token] ||= SecureRandom.base64(32))
    ip = request.remote_ip
    last_offer = @product.last_offer(ip,offer_token)

    if last_offer
      if last_offer.counter?
        @message = "Come on you want our new offer?"
      elsif last_offer.last?
        @message = "Hey, this is the best we can do. Want it?"
      elsif last_offer.share?
        @message = "Want a better offer? Share & Unlock"
      end
    end

  end

end
