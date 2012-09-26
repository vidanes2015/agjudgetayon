class AdminController < ApplicationController
  

  def login
    session[:judge_id] = nil
    if request.post?
      if (params[:username]=="admin" and params[:password]=="awesome")
        session[:judge_id] = 'admin'
        redirect_to(:controller=>'judges')
      else
        judge = Judge.authenticate(params[:username], params[:password])
        if judge
          session[:judge_id] = judge.id
          redirect_to(record_scores_judge_url(judge))
        else
          flash.now[:notice] = "Invalid username/password combination"
        end
      end
    end
  end

  def logout
    session[:judge_id] = nil
    flash[:notice] = "Logged Out"
    redirect_to(:action => "login")
  end
  
end
