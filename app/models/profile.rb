class Profile < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :name, :city, :state, :zip, :phone

  validate :valid_address?
  attr_accessible :name,:city,:address1,:address2,:state,:zip,:phone,:user_id,:website

  def address
    add = [self.address1, self.address2].compact
    return(add*", ")
  end
private

  def valid_address?
    if(self.address1 and self.address2)
      self.errors.add(:address1, "^Hey, please enter address line1 or line2") if(self.address1.strip.blank? and self.address2.strip.blank?)
    end
  end
end
