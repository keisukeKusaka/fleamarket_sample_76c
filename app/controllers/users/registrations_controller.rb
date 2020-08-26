# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

    def new
      @user = User.new
    end

    def create
      @user = User.new(sign_up_params)
      unless @user.valid?
        flash.now[:alert] = @user.errors.full_messages
        render :new and return
      end
      session["devise.regist_data"] = {user: @user.attributes}
      session["devise.regist_data"][:user]["password"] = params[:user][:password]
      @profile = @user.build_profile
      render :new_profile
    end

    def create_profile
      @user = User.new(session["devise.regist_data"]["user"])
      @profile = Profile.new(profile_params)

      unless @profile.valid?
        flash.now[:alert] = @profile.errors.full_messages
        render :new_profile and return
      end
      session["devise.regist_data"].merge!(profile: @user.build_profile(@profile.attributes).attributes)
      @address = @user.addresses.build
      render :new_address
    end

    def create_address
      @user = User.new(session["devise.regist_data"]["user"])
      @profile = Profile.new(session["devise.regist_data"]["profile"])
      @address = Address.new(address_params)
      unless @address.valid?
        flash.now[:alert] = @address.errors.full_messages
        render :new_address and return
      end

      @user.save

      @profile.user_id = @user.id
      @profile.save

      @address.user_id = @user.id
      @address.save

      session["devise.regist_data"].clear
      sign_in(:user, @user)
    end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
  end

  def profile_params
    params.require(:profile).permit(:family_name, :family_name_kana, :first_name, :first_name_kana, :birthday)
  end

  def address_params
    params.require(:address).permit(:post_family_name, :post_family_name_kana, :post_first_name, :post_first_name_kana, :postal_code, :prefecture_id, :city, :address, :building, :phone_number)
  end

end