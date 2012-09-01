# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
 helper :all # include all helpers, all the time
  include AuthenticatedSystem # logged_in? and current_user
  include ApplicationHelper
  before_filter :prepare_for_mobile
  helper_method :mobile_device?
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def check_login
    if logged_in? # and session[:page_access] == true
      flash.discard
    else
      flash[:notice] = "Please login first"
      redirect_to root_path
    end
  end

   def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
       if request.user_agent =~ /Mobile|Android|webOS|iPad|iOS/         
         return true
       else
         return false
       end
    end
  end

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    #request.format = :mobile if mobile_device?
  end

end
