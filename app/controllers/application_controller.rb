# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout "default"
  before_filter :authorize_admin, :except => [:login, :logout, :new, :create]
  
  helper :all # include all helpers, all the time
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'be94de8b33c45595edea9c2c11e708bb'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
protected
  def authorize_admin
    unless session[:judge_id] == 'admin'
      flash[:notice] = "Please log in"
      redirect_to :controller => :admin, :action => :login
    end
  end
  
  def authorize_judge_or_admin
    id = params[:judge_id] || params[:id]
    unless (session[:judge_id]==id.to_i || session[:judge_id] == 'admin')
      flash[:notice] = "Please log in"
      redirect_to :controller => :admin, :action => :login
    end
  end
  
  # def authorize_add_score
  #   unless (session[:judge_id]==params[:judge_id].to_i || session[:judge_id] == 'admin')
  #     flash[:notice] = "Please log in"
  #     redirect_to :controller => :admin, :action => :login
  #   end
  # end
  # 
  # def authorize_lock_scores
  #   unless (session[:judge_id]==params[:judge_id].to_i || session[:judge_id] == 'admin')
  #     flash[:notice] = "Please log in"
  #     redirect_to :controller => :admin, :action => :login
  #   end
  # end
end
