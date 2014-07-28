class Message < ActiveRecord::Base
  belongs_to :user
  has_one :coupon
  
  def self.send_mdm(coupon)
    message = self.new
    message.send_phone = Rails.application.secrets.send_phone
    message.dest_phone = coupon.user.phone
    message.msg_body = self.send_mdm_message(coupon)
    message.subject = "NEW FACE"
    message.send_name = coupon.user.name
    message.sent_at = Time.now + 5.seconds
    message.save
    message.user = coupon.user
    message.coupon = coupon
    message.save
    message.send_lms
    return message
  end
  
  def self.send_mdm_0728(coupon)
    message = self.new
    message.send_phone = Rails.application.secrets.send_phone
    message.dest_phone = coupon.user.phone
    message.msg_body = self.send_mdm_0728_message(coupon)
    message.subject = "NEW FACE"
    message.send_name = coupon.user.name
    message.sent_at = Time.now + 5.seconds
    message.save
    message.user = coupon.user
    message.coupon = coupon
    message.save
    # message.send_lms
    return message
  end
  
  def self.send_to(coupon)
    message = self.new
    message.send_phone = Rails.application.secrets.send_phone
    message.dest_phone = coupon.user.phone
    message.msg_body = self.send_message(coupon)
    message.subject = "NEW FACE"
    message.send_name = coupon.user.name
    message.sent_at = Time.now + 5.seconds
    message.save
    message.user = coupon.user
    message.coupon = coupon
    message.save
    message.send_lms
    return message
  end
                  
  def self.send_message(coupon)
"
"+coupon.user.name+"님
오휘를 처음 만난 오늘부터
아름다워질거예요


새로운 NEW FACE를 위해 넘버원 에센스 본품(35ml)과 CC쿠션 미니어처를 드립니다.
세안 후 3초,NO.1 에센스로 맨 얼굴의 힘을 먼저 키워주세요.


쿠폰받기:
http://ohui-newface.co.kr/" + coupon.code + "

쿠폰 사용기간 :
2014.7.1(화)~2014.8.3(일)


<<지금 매장을 방문해주시면
지친 피부를 충전해주는 오휘의 밀리언 셀러
'넘버원 에센스' 5일 체험분을 드립니다.>>


모바일 쿠폰 사용 유의사항
- 본 행사는 오휘 첫 구매 고객에게만 제공되는 혜택입니다. (오휘 기존고객 제외, 퍼프류 구매 제외)
- 오휘 멤버십에 가입하셔야 혜택을 누릴 수 있습니다.
- 전국 백화점 매장(오프라인)에서만 사용가능합니다.
- 쿠폰은 한정 수량으로 조기 소진될 수 있으며, 1인 1회 한정으로 중복 지급되지 않습니다.
 
"
 end           
                  
  def self.send_mdm_message(coupon)
"
★오휘 NEW FACE★

오휘를 만나 아름다워질 오늘이 기대되지 되지 않으세요?♥

아직 사용하지 않은 NEW FACE 쿠폰이 있으시다면,
하루 빨리 오휘 매장을 방문해주세요!

매장을 방문해주시면
지친 피부를 충전해주는 오휘의 밀리언 셀러 
'넘버원 에센스' 5일 체험분을 드립니다.

세안 후 3초,NO.1 에센스로 맨 얼굴의 힘을 먼저 키워주세요.

넘버원 에센스 5일 체험분 free gift 쿠폰 받기♥
↓↓↓↓
http://ohui-newface.co.kr/mobile/mdm


새로운 NEW FACE를 위해 오휘 제품을 첫 구매하시면
100만개 판매 밀리언 셀러 넘버원 에센스 '본품'(35ml)과
CC쿠션 미니어처를 드립니다.

자세히 보기♥
↓↓↓
http://ohui-newface.co.kr/" + coupon.code + "

※위 링크는 LG생활건강에서 보내는 내용입니다. 안심하고 클릭하셔도 됩니다. 


쿠폰 사용기간 :
2014.7.1(화)~2014.8.3(일)

모바일 쿠폰 사용 유의사항
- NEW FACE 쿠폰은 오휘 첫 구매 고객에게만 제공되는 혜택입니다. (오휘 기존고객 제외, 퍼프류 구매 제외)
- 오휘 멤버십에 가입하셔야 혜택을 누릴 수 있습니다.
- 전국 백화점 매장(오프라인)에서만 사용가능합니다.
- 모든 쿠폰은 한정 수량으로 조기 소진될 수 있으며, 1인 1회 한정으로 중복 지급되지 않습니다.
"
 end

  def self.send_mdm_0728_message(coupon)
"

★오휘 NEW FACE★

오휘를 만나 아름다워질 오늘이 기대되지 되지 않으세요?♥

아직 사용하지 않은 NEW FACE 쿠폰이 있으시다면,
하루 빨리 오휘 매장을 방문해주세요!

매장을 방문해주시면
지친 피부를 충전해주는 오휘의 밀리언 셀러 
'넘버원 에센스' 5일 체험분을 드립니다.

세안 후 3초,NO.1 에센스로 맨 얼굴의 힘을 먼저 키워주세요.

넘버원 에센스 5일 체험분 free gift 쿠폰 받기♥
↓↓↓↓
http://ohui-newface.co.kr/mobile/mdm


새로운 NEW FACE를 위해 오휘 제품을 첫 구매하시면
100만개 판매 밀리언 셀러 넘버원 에센스 '본품'(35ml)과
CC쿠션 미니어처를 드립니다.

자세히 보기♥
↓↓↓
http://ohui-newface.co.kr/" + coupon.code + "

※위 링크는 LG생활건강에서 보내는 내용입니다. 안심하고 클릭하셔도 됩니다. 


쿠폰 사용기간 :
2014년 8월 3일 일요일까지

모바일 쿠폰 사용 유의사항
- NEW FACE 쿠폰은 오휘 첫 구매 고객에게만 제공되는 혜택입니다. (오휘 기존고객 제외, 퍼프류 구매 제외)
- 오휘 멤버십에 가입하셔야 혜택을 누릴 수 있습니다.
- 전국 백화점 매장(오프라인)에서만 사용가능합니다.
- 모든 쿠폰은 한정 수량으로 조기 소진될 수 있으며, 1인 1회 한정으로 중복 지급되지 않습니다.
"
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
    self.cmid = cmid
    self.save
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
    self.cmid = cmid
    self.save
    logger.info "@@문자발송"
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
