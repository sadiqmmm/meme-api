class RegistrationsController < Devise::RegistrationsController

  def create
    build_resource(sign_up_params)

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        render :json => resource.as_json(:auth_token => resource.authentication_token, :email => resource.email), :status=>201
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        render :json => resource.as_json(:auth_token => resource.authentication_token, :email => resource.email), :status=>201
      end
    else
      clean_up_passwords resource
      warden.custom_failure!
    end
  end
  
end