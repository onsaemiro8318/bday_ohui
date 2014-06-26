class User < ActiveRecord::Base
  devise :database_authenticatable
  
  has_many :messages
  has_many :access_logs
  has_one :coupon
  
  validates :agree, acceptance: true
  validates :agree2, acceptance: true
  # validates :birthday, presence: true
  validates :name, presence: true
  validates :phone, presence: true
  validates :phone, uniqueness: true

  attr_accessor :birthday_month, :birthday_day

  def send_survey
    Message.send_survey_to(self)
  end
  
  def send_120_survey(phone)
    Message.send_120_survey_to(phone)
  end
    
  def self.convert_phone(phone)
    phone = phone.insert(3, "-").insert(8, "-")
  end
  
  def self.send_survey_message
    offset_start = 1
    finish = all.count
    until offset_start > finish
      all.limit(100).offset(offset_start).each do |u|
        puts u.name
        u.send_survey
      end
      offset_start = offset_start + 100
    end
  end
  
  def self.coupon_used_counts
    result = User.select("
      date(convert_tz(coupons.updated_at,'+00:00','+09:00')) used_date,
      count(*) used_count")
      .joins(:coupon)
      .where(coupons: {status: "used"})
      .group("date(convert_tz(coupons.updated_at,'+00:00','+09:00'))")
      .order("coupons.updated_at")
  end
  
  def self.coupon_used_users
    result = User.includes(:coupon)
      .where(coupons: {status: "used"})
      .order("coupons.updated_at DESC")
  end
  
  def self.count_by_device_type
    result = self.select(
      "sum(case when users.device = 'pc' then 1 else 0 end) as pc_count, 
      sum(case when users.device = 'mobile' then 1 else 0 end) as mobile_count, 
      count(*) as total_count")
  end
  
  def self.user_120
    phones = Array.new
    User.where(phone: User.coupon_users).each do |user|
      phones << user.phone
    end
    user_120 = User.coupon_users - phones
  end
  
  def self.coupon_users
    ['010-8812-5111']
  end
end
