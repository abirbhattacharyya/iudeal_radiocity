class Offer < ActiveRecord::Base
  belongs_to :product
  has_one :payment, :dependent => :nullify

  attr_accessible :product_id, :price, :response, :token, :ip, :counter
  
  def accepted?
    (self.response.eql? "accepted")
  end

  def paid?
    (self.response.eql? "paid")
  end

  def counter?
    (self.response.eql? "counter")
  end

  def last?
    (self.response.eql? "last")
  end

  def share?
    (self.response.eql? "share")
  end
end
