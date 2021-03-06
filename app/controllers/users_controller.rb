class UsersController < ApplicationController
  before_action :require_no_authentication, only: [:new, :create]
  before_action :can_change, only: [:edit, :update]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      Signup.confirm_email(@user).deliver

      redirect_to @user, notice: t('flash.notice.user_created')
    else
      render action: :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      redirect_to @user, :notice => t('flash.notice.user_updated')
    else
      render action: :edit
    end
  end

  private
    def user_params
      params.
      require(:user).
      permit(:email, :full_name, :location, :password, :password_confirmation, :bio)
    end

    def can_change
      unless user_signed_in? && current_user == user
        redirect_to user_path(params[:id])
      end
    end

    def user
      @user ||= User.find(params[:id])
    end
end
