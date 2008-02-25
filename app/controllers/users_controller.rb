class UsersController < ApplicationController
  before_filter :find_user, :only => [:profile, :destroy, :edit_password, :update_password]
  
  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    raise ActiveRecord::RecordInvalid.new(@user) unless @user.valid?
    @user.register!
    
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!<br />You will receive an email in a few minutes with further instructions on how to activate your account."
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = "Your account is now ready.<br />Thanks for signing up!"
    end
    redirect_back_or_default('/')
  end
  
  def edit_password
    # render edit_password.html.erb
  end
  
  def update_password    
    if current_user == @user
      current_password, new_password, new_password_confirmation = params[:current_password], params[:new_password], params[:new_password_confirmation]
      
      if User.encrypt(current_password, @user.salt) == @user.crypted_password
        if new_password == new_password_confirmation
          if new_password.blank? || new_password_confirmation.blank?
            flash[:error] = "You cannot set a blank password."
            redirect_to edit_password_user_url(@user)
          else
            @user.password = new_password
            @user.password_confirmation = new_password_confirmation
            @user.save
            flash[:notice] = "Your password has been updated."
            redirect_to profile_url(@user)
          end
        else
          flash[:error] = "Your new password and it's confirmation don't match."
          redirect_to edit_password_user_url(@user)
        end
      else
        flash[:error] = "Your current password is not correct. Your password has not been updated."
        redirect_to edit_password_user_url(@user)
      end
    else
      flash[:error] = "You cannot update another user's password!"
      redirect_to edit_password_user_url(@user)
    end
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

end
