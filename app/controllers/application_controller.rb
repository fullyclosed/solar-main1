class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up) do |u|
        u.permit(:first_name, :last_name, :email,  :password,  :lenguage)
      end
  
      devise_parameter_sanitizer.permit(:account_update) do |u|
        u.permit(:first_name, :last_name, :email, :password, :current_password)
      end
    end
end
