require 'writeexcel'
class Coupon < ActiveRecord::Base
  belongs_to :user
  
  scope :used, -> { where status: 'used' }
  scope :not_used, -> { where status: 'not_used' }
  
  def self.log_file
    file = File.new("ohui_production_07281420.log")
    lines = file.readlines
    greps = lines.grep(/Parameters: {"contraints"=>{"code"=>/)
    greps
    coupons = []
    greps.each_with_index do |grep, i|
      hash = eval grep.partition("ters: ").last
      log_time = grep.partition("INFO --").first
      created_at = DateTime.parse(log_time).change(offset:"+0900")
      code = hash["code"]
      coupon = {code: code, created_at: created_at}
      start_time = DateTime.parse "2014-07-27 00:00:00 +0900"
      finish_time = DateTime.parse "2014-07-27 23:59:59 +0900"
      if code =~ /[a-z]{5}-\d{4}/ and start_time < created_at and created_at > finish_time
        coupons << code
      end
    end
    coupons.uniq
  end
  
  def send_message
    Message.send_to(self)
  end
  
  def send_retention
    Message.send_mdm_0728(self)
  end
  
  def self.send_retention_message
    offset_start = 803
    finish = not_used.count
    until offset_start > finish
      offset_start = offset_start + 100
      not_used.where("created_at < ?", DateTime.parse("2014-07-10 23:59:59")).limit(100).offset(offset_start).each do |c|
        unless c.user.nil?
          puts c.user.name
           # c.send_retention
        end
      end
    end
  end
  
  def self.send_survey_message(phones)
    i = 0
    # receivers = Coupon.joins(:user).includes(:user).where("users.phone" => User.user_120)
    # receivers = Coupon.used.joins(:user).includes(:user).where("users.phone" => User.coupon_users)
    phones.each do |phone|
      Message.send_120_survey_to(phone)
      i += 1
      puts i.to_s + "/" + phone
    end
  end
  
  def random_code
    alphabet = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z) * 3
    digit = %w(1 2 3 4 5 6 7 8 9 0) * 2
    code = alphabet.shuffle.join[0..4] + "-" + digit.shuffle.join[0..3]
    code
  end
  
  def self.write_excel
    workbook = WriteExcel.new('random_code.xls')
    worksheet  = workbook.add_worksheet
    6000.times do |i|
      n = i + 1
      worksheet.write(n, 0, n)
      worksheet.write(n, 1, Coupon.new.random_code)
    end
    workbook.close
  end
    
  def is_used?
    if status == "used"
      return "used"
      
    elsif status == "not_used"
      return "not_used"

    end
  end

  def confirm
    status = "used"
    used_at = Time.now
    self.save
  end

end
