class AdminsController < ApplicationController
  
  def login
    if Admin.find(:all).empty?
      redirect_to new_admin_url
    end
    session[:judge_id] = nil
    if request.post?
      if (params[:username]=="admin")
        admin = Admin.authenticate(params[:password])
        if admin 
          session[:judge_id] = 'admin'
          redirect_to(:controller=>'pageants')
        else
          flash.now[:notice] = "Invalid username/password combination"
        end
      else
        judge = Judge.authenticate(params[:username], params[:password])
        if judge
          session[:judge_id] = judge.id
          redirect_to(record_scores_pageant_judge_url(judge.pageant, judge))
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
  
  def new
    if not Admin.find(:all).empty?
      redirect_to( :action=> 'login')
    end
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(params[:admin])

    if @admin.save
      flash[:notice] = "Administrator password successfully created."
      redirect_to(:action => "login")
    else
      render :action => "new"
    end
  end
  
end
