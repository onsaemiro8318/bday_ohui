class User < ActiveRecord::Base
  devise :database_authenticatable
  
  has_many :messages, dependent: :destroy
  has_many :access_logs, dependent: :destroy
  has_one :coupon, dependent: :destroy
  
  validates :agree, acceptance: true
  validates :agree2, acceptance: true
  # validates :birthday, presence: true
  validates :name, presence: true
  validates :phone, presence: true
  validates :phone, uniqueness: true

  attr_accessor :birthday_month, :birthday_day
  # attr_accessor :created_at

  def self.offset_id
    offset = 20000
    users = User.all
        # users = User.limit(5)
    users.each do |user|
      new_user = user.attributes
      new_user["id"] = new_user["id"] + offset
      user.destroy
      User.create(new_user)
    end
    access_logs = AccessLog.all
        # access_logs = AccessLog.limit(5)
    access_logs.each do |access_log|
      new_access_log = access_log.attributes
      new_access_log["id"] = new_access_log["id"] + offset
      new_access_log["user_id"] = new_access_log["user_id"] + offset
      access_log.destroy
      AccessLog.create(new_access_log)
    end
    coupons = Coupon.all
        # coupons = Coupon.limit(5)
    coupons.each do |coupon|
      new_coupon = coupon.attributes
      new_coupon["id"] = new_coupon["id"] + offset
      new_coupon["user_id"] = new_coupon["user_id"] + offset
      coupon.destroy
      Coupon.create(new_coupon)
    end
    messages = Message.all
        # messages = Message.limit(5)
    messages.each do |message|
      new_message = message.attributes
      new_message["id"] = new_message["id"] + offset
      unless new_message["user_id"].nil?
        new_message["user_id"] = new_message["user_id"] + offset
      else
        new_message["user_id"] = nil
      end
      message.destroy
      Message.create(new_message)
    end
  end


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
  
  def self.write_excel_0724
    users = User.joins(:coupon).where(coupons:{status: "not_used"})
        .where("coupons.created_At < ?",  DateTime.parse("2014-07-10 23:59:59 +0900"))
    workbook = WriteExcel.new('user_list.xls')
    worksheet  = workbook.add_worksheet
    users.each_with_index do |user, i|
      worksheet.write(i, 0, i+1)
      worksheet.write(i, 1 , user.name)
      worksheet.write(i, 2 , user.phone)
    end
    workbook.close
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
  
  
  def self.first_day()
    self.select("created_at").order("created_at").limit(1) 
  end
  
  
  
  def self.paginate_by_week(page)
    page ||= 1 
    page = page.to_i
    start_date = (DateTime.now-DateTime.now.wday-7*(page-1)).beginning_of_day
    end_date = (DateTime.now+(7-DateTime.now.wday)-7*(page-1)).beginning_of_day
    self.source_by_weekday(start_date,end_date)
  end
  
  def self.source_by_weekday(start_date, end_date)
    self.select("source
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 1 then 1 else 0 end) as 'sun'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 2 then 1 else 0 end) as 'mon'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 3 then 1 else 0 end) as 'tue'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 4 then 1 else 0 end) as 'wed'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 5 then 1 else 0 end) as 'thu'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 6 then 1 else 0 end) as 'fri'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 7 then 1 else 0 end) as 'sat' ")
        .where("created_at >= ? and created_at < ?", start_date, end_date)
        .group("source").order("source")
  end
  
  def self.paginate_by_week_sum(page)
    page ||= 1 
    page = page.to_i
    start_date = (DateTime.now-DateTime.now.wday-7*(page-1)).beginning_of_day
    end_date = (DateTime.now+(7-DateTime.now.wday)-7*(page-1)).beginning_of_day
    self.source_by_weekday_sum(start_date,end_date)
  end
  
  def self.source_by_weekday_sum(start_date,end_date)
    self.select(
      "sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 1 then 1 else 0 end) as 'sun'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 2 then 1 else 0 end) as 'mon'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 3 then 1 else 0 end) as 'tue'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 4 then 1 else 0 end) as 'wed'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 5 then 1 else 0 end) as 'thu'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 6 then 1 else 0 end) as 'fri'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 7 then 1 else 0 end) as 'sat' ")
        .where("created_at >= ? and created_at < ?", start_date, end_date)
  end
  
  def self.log_file(day)
    lines = []
    file = File.new("log/production08.log")
      lines = lines + file.readlines
    file.close
    file = File.new("log/production09.log")
      lines = lines + file.readlines
    file.close
    file = File.new("log/production10.log")
      lines = lines + file.readlines
    file.close
    greps = lines.grep(/, "user"=>{"b/)
    users = []
    greps.each_with_index do |grep, i|
      hash = eval grep.partition("ters: ").last
      log_time = grep.partition("INFO --").first
      created_at = DateTime.parse(log_time).change(offset:"+0900")
      user = hash["user"]
      user["created_at"] = created_at
      start_time = DateTime.parse("2014-07-"+day.to_s+" 00:00:00 +0900")
      finish_time = DateTime.parse("2014-07-"+day.to_s+" 23:59:59 +0900")
      if start_time <= created_at and created_at <= finish_time
        u = User.create(user)
        coupon = Coupon.new
        coupon.code = coupon.random_code
        coupon.user = u
        coupon.save
        users << u
      end
    end
    users
    # greps.each_with_index do |s, i|
    #   puts "@@"+i.to_s
    #   begin
    #     user = User.new(eval(s[64..-2])["user"])
    #   rescue SyntaxError
    #     user = User.new(eval(s[62..-2])["user"])
    #   end
    #   begin
    #     # user.created_at = DateTime.parse(s).change(offset:"+0900")
    #   rescue ArgumentError
    #     # user.created_at = DateTime.parse('2014-07-22 03:14:00').change(offset:"+0900")
    #   end
    #   # user.save()
    # end
  end
  
  def self.write_excel
    workbook = WriteExcel.new('retention_user_list_'+Time.now.strftime("%m%d%h")+'.xls')
    worksheet  = workbook.add_worksheet
    users = User.joins(:coupon).where("coupons.status" => "not_used").where("coupons.created_at > ?", DateTime.parse("2014-07-10 23:59:59"))
    users.each_with_index do |user, i|
      worksheet.write(i, 0, i+1)
      worksheet.write(i, 1, user.name)
      worksheet.write(i, 2, user.phone)
      worksheet.write(i, 3, user.created_at)
    end
    workbook.close
  end
  
  
end
