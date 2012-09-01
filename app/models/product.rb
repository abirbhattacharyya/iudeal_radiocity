class Product < ActiveRecord::Base
   belongs_to :user
   has_many :offers

attr_accessible :description, :is_live, :name, :quantity, :regular_price, :target_price, :user_id, :image, :image_remote_url, :product_type
attr_accessor :image_remote_url
attr_accessor :ip_address

RESPONSES = ["counter","last","share"]
 TYPES = {
    :ticket=> 1,
    :package => 2    
  }

  validates_attachment :image, :content_type => {:message => "Hey, Upload a JPEG, GIF, or PNG image please!", :content_type => ["image/jpg", "image/png", "image/gif", "image/bmp", "image/jpeg"] },
  :size => { :in => 0..5.megabytes }

  has_attached_file :image, {
  	:path => ":rails_root/public/products/:id/:style/:filename",
  	:url => "/products/:id/:style/:filename",
  	:default_url => "/assets/mylogo.jpg",
  	 :styles => { :medium => "250x" }
  	}
	


  validates_presence_of :name, :message => "Hey, name can't be blank"
  validates_presence_of :description, :message => "Hey, description can't be blank"
  validates_presence_of :target_price, :message => "Hey, price can't be blank"
  validates_presence_of :image, :message => "Hey, image can't be blank"
  validates_uniqueness_of :name, :scope => [:user_id, :target_price], :message => "Hey, name already been taken"

#  validate :valid_price?




  before_validation :download_remote_image, :if => :image_url_provided?

  def color
    self.color_description.gsub(/\d+/, '').strip
  end

  def current_price(ip,token)
    offer = last_offer(ip,token)
    if offer
      return offer.price
    else
      return self.regular_price
    end
  end


  def show_name
    str = self.name    
    str
  end
  def reg_price
    (self.regular_price.to_f)
  end

  def min_price
    (self.regular_price.to_f*0.3)
  end
  def max_price
    new_price = self.regular_price + (self.regular_price.to_f*0.2)
    new_price
  end

  def joys

    return Discount.count(:conditions => ["product_id = ? and ip is not null",self.id])

  end

  def last_offer(ip,token)
    offer = Offer.find(:last,:conditions => ["product_id = ? AND response in (?) AND ip = ? AND token = ?",self.id, RESPONSES,ip,token])
    offer
  end

  
  private

  def image_url_provided?
    !self.image_remote_url.blank?
  end

  def download_remote_image
    self.image = do_download_remote_image
    #self.image_remote_url = image_url
  end

  def do_download_remote_image
    io = open(URI.parse(image_remote_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    
  end
end
