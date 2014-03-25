class Admin::ViralActionsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  def index
    @viral_actions = ViralAction.order("id desc").page(params[:page]).per(200)
    @viral_action_counts = ViralAction.select("sum(case when viral_actions.device = 'pc' then 1 else 0 end) as pc_count, sum(case when viral_actions.device = 'mobile' then 1 else 0 end) as mobile_count, count(*) as total_count")
  end
end
