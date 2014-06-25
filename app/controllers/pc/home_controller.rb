class Pc::HomeController < ApplicationController
  def index
    @user = User.new
    @code = '<a href="https://ohui-newface.co.kr/?s=blog">
    <img src="http://ohui-newface.co.kr/blog_730.jpg"/></a>'
  end
end
