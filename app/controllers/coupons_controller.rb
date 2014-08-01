class CouponsController < ApplicationController
  layout 'mobile'
  before_action :set_coupon, only: [:destroy, :update, :edit, :show]
  skip_before_action  :verify_authenticity_token
  def update
    @coupon = Coupon.find_by_code(params[:code])
    if @coupon.nil? 
      redirect_to root_path
    else
      @coupon.used_at=Time.now
      respond_to do |format|
        if @coupon.update(coupon_params)
          format.html { redirect_to coupon_path(@coupon.code), notice: 'Coupon was successfully updated.' }
          format.json { render action: 'show', status: :ok, location: @coupon }
        else
          format.html { render action: 'edit' }
          format.json { render json: @coupon.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
    @coupon = Coupon.find_by_code(params[:code])
    unless @coupon.nil?
      if @coupon.is_used? == "used"
        redirect_to coupon_path(@coupon.code)
      end
    else
      @coupon = Coupon.new
      @coupon.code = "temporary"
    end
  end
  
  def show
    @coupon = Coupon.find_by_code(params[:code])
    unless @coupon.nil?
      if @coupon.is_used? == "used"
      else
        redirect_to edit_coupon_path(@coupon.code)
      end
    else
      redirect_to edit_coupon_path(1)
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coupon
      @coupon = Coupon.find_by_code(params[:code])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def coupon_params
      params[:user] = {status: "used"}
    end
    
end
