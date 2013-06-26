class SessionsController < Devise::SessionsController
 
  skip_before_filter :authenticate_user!, :only => :create
 
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)

    respond_to do |format|
      format.json do
        render :json => { :response => 'ok', :auth_token => current_user.authentication_token }.to_json, :status => :ok
      end
    end
  end
 
  def destroy
    # expire auth token
    user = User.where(:authentication_token => params[:authentication_token]).first
    user.reset_authentication_token!
    render :json => { :message => ["Session deleted."] },  :success => true, :status => :ok
  end
 
  private
 
  def invalid_login_attempt
    warden.custom_failure!
    render :json => { :errors => ["Invalid email or password."] },  :success => false, :status => :unauthorized
  end
end