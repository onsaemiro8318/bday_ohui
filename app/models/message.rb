class Message < ActiveRecord::Base
  belongs_to :user
  has_one :coupon
  
  def self.send_to(coupon)
    message = self.new
    message.send_phone = Rails.application.secrets.send_phone
    message.dest_phone = coupon.user.phone
    message.msg_body = self.send_message(coupon)
    message.subject = "Skin Birthday"
    message.send_name = coupon.user.name
    message.sent_at = Time.now + 5.seconds
    message.save
    message.user = coupon.user
    message.coupon = coupon
    message.save
    message.send_lms
    return message
  end
  
  def self.send_retention_to(user)
    message = self.new
    message.send_phone = Rails.application.secrets.send_phone
    message.dest_phone = user.phone
    message.msg_body = self.send_retention()
    message.subject = "Skin Birthday"
    message.send_name = user.name
    message.sent_at = Time.now + 3.seconds
    message.save
    message.user = user
    message.save
    result = message.send_lms
    message.cmid = result["cmid"]
    message.result = result["result_code"]
    message.save
    return message
  end
  
  def self.send_survey_to(user)
    message = self.new
    message.send_phone = Rails.application.secrets.send_phone
    message.dest_phone = user.phone 
    message.msg_body = self.send_survey(user)
    message.subject = "Skin Birthday"
    message.send_name = user.name
    message.sent_at = Time.now + 2.seconds
    message.save
    message.user = user
    message.save
    result = message.send_lms
    message.cmid = result["cmid"]
    message.result = result["result_code"]
    return message
  end
  
  def self.send_survey(user)
    "
"+user.name+"님,
숨37 Skin Birthday
이벤트에 참여해주셔서 감사합니다!

더 좋은 이벤트를 위해,
간단한 설문에 답변 부탁드려요^^

설문링크 >
https://birthday.su-m37.co.kr/survey?p="+user.phone+"

감사합니다!
수신거부: 080-863-5542
"
  end
  
  def self.send_120_survey(phone)
    "
숨37 Skin Birthday
이벤트에 참여해주셔서 감사합니다!

더 좋은 이벤트를 위해,
간단한 설문에 답변 부탁드려요^^

설문링크 >
https://birthday.su-m37.co.kr/survey?p="+phone+"

감사합니다!
수신거부: 080-863-5542
"
  end
  
  def self.send_080
"수신거부: 080-863-5542"
  end
  
  def self.send_080_to_today
    messages = Message.where(created_at:[Time.now.beginning_of_day..Time.now.end_of_day]).where("user_id is not null")
    messages.each do |m|
      Message.send_080_to(m.send_phone, m.dest_phone)
    end
  end
  
  def self.send_080_to(send_phone, dest_phone)
    message = self.new
    message.send_phone = send_phone
    message.dest_phone = dest_phone 
    message.msg_body = self.send_080
    # message.subject = "Skin Birthday"
    # message.send_name = user.name
    message.sent_at = Time.now + 2.seconds
    message.save
    # message.user = user
    message.save
    result = message.send_sms
    message.cmid = result["cmid"]
    message.result = result["result_code"]
    return message
  end
  
  def self.send_120_survey_to(phone)
    message = self.new
    message.send_phone = Rails.application.secrets.send_phone
    message.dest_phone = phone 
    message.msg_body = self.send_120_survey(phone)
    message.subject = "Skin Birthday"
    # message.send_name = user.name
    message.sent_at = Time.now + 2.seconds
    message.save
    # message.user = user
    message.save
    result = message.send_lms
    message.cmid = result["cmid"]
    message.result = result["result_code"]
    return message
  end
  
  def self.send_retention
    "
    [Skin Birthday]
    숨37, 이번엔 수분크림!
    올 여름 워터젤 크림을 
    선물로 받아보세요! 

    쿠폰 받기: 
    https://birthday.su-m37.co.kr/mobile/index?s=lms1

    해당 쿠폰은 숨37 브랜드 첫 구매 고객만 사용 가능합니다.
    숨37 멤버십에 가입하셔야 혜택을 누릴 수 있습니다.
    전국 백화점 매장에서만 사용가능합니다.
    쿠폰은 한정 수량으로 조기 소진될 수 있습니다.
    1인 1회 한정

    수신거부 : 080-863-5542
"
  end
  
  def self.send_message(coupon)
    "
"+coupon.user.name+"님
이제부터 새로워지는 얼굴,
오늘의 선물을 드립니다.
셀 파워 넘버원 에센스(35ml)와
CC쿠션 미니어처를 드립니다.

쿠폰 사용기간 : ~ 8월 3일(일)

쿠폰받기:
" + Rails.application.secrets.url + "/" + coupon.code + "
모바일 쿠폰 사용 유의사항
· 본 행사는 첫 구매 고객에게만 제공되는 혜택입니다.(기존고객 제외)
· 전국 백화점 매장(오프라인)에서만 사용 가능합니다.(면세점 제외)
· 사은품은 중복 지급되지 않으며, 한정 수량으로 조기 품절 될 수 있습니다."
  end
  
  def send_sms
    url = "http://api.openapi.io/ppurio/1/message/sms/minivertising"
    api_key = Rails.application.secrets.apistore_key
    time = (Time.now + 1.seconds)
    res = RestClient.post(url,
      {
        "send_time" => time.strftime("%Y%m%d%H%M%S"), 
        "dest_phone" => self.dest_phone, 
        "dest_name" => "LG",
        "send_phone" => self.send_phone, 
        "send_name" => self.send_name,
        "subject" => self.subject,
        "apiVersion" => "1",
        "id" => "minivertising",
        "msg_body" => self.msg_body
      },
      content_type: 'multipart/form-data',
      'x-waple-authorization' => api_key
    )
    parsed_result = JSON.parse(res)
    cmid = parsed_result["cmid"]
    call_status = String.new
    start = Time.new
    during_time = 0
    puts res
    return JSON.parse(res)
  end
  
  
  def send_lms
    url = "http://api.openapi.io/ppurio/1/message/lms/minivertising"
    api_key = Rails.application.secrets.apistore_key
    time = (Time.now + 1.seconds)
    res = RestClient.post(url,
      {
        "send_time" => time.strftime("%Y%m%d%H%M%S"), 
        "dest_phone" => self.dest_phone, 
        "dest_name" => "LG",
        "send_phone" => self.send_phone, 
        "send_name" => self.send_name,
        "subject" => self.subject,
        "apiVersion" => "1",
        "id" => "minivertising",
        "msg_body" => self.msg_body
      },
      content_type: 'multipart/form-data',
      'x-waple-authorization' => api_key
    )
    parsed_result = JSON.parse(res)
    cmid = parsed_result["cmid"]
    call_status = String.new
    start = Time.new
    during_time = 0
    puts res
    return JSON.parse(res)
  end
  
  def waiting_for_result(interval_time, finish_time)
    start_time = Time.now
    during_time = Time.now - start_time
    result = false
    while finish_time > during_time
      during_time = Time.now - start_time
      sleep(interval_time)
    end
    if finish_time < during_time
      result = true
    end
    return result
  end
  
  def report
    api_key = Rails.application.secrets.apistore_key
    url = "http://api.openapi.io/ppurio/1/message/report/minivertising?cmid="+self.cmid
    result = RestClient.get(url, 'x-waple-authorization' => api_key)
    call_status = JSON.parse(result)["call_status"].to_s
    # self.sent_at = time
    self.result = result
    self.call_status = call_status
    self.save!    
    return call_status
  end
  

end
