class ContestantsController < ApplicationController
  
  before_filter :find_pageant

  def show
    @contestant = @pageant.contestants.find(params[:id])
    @rounds = @pageant.rounds.find(:all, :order=>'position')
    @judges = @pageant.judges.find(:all, :order=>'alias')
    @ranking = Score.rankings(@pageant)[@contestant.id]
    @round_rankings = Hash.new
    @rounds.each {|r| @round_rankings[r.id] = Score.round_rankings(r)[@contestant.id]}
    @judge_rankings = Hash.new
    @judges.each {|j| @judge_rankings[j.id] = Score.judge_rankings(j)[@contestant.id]}

    session[:return_to] = request.request_uri
  end

  def new
    @contestant = Contestant.new
  end

  def edit
    @contestant = @pageant.contestants.find(params[:id])
  end

  def create
    @contestant = Contestant.new(params[:contestant])

    if @pageant.contestants << @contestant
      flash[:notice] = "Contestant #{@contestant.name} was successfully created."
      redirect_to pageant_url(@pageant)
    else
      render :action => "new"
    end
  end

  def update
    @contestant = @pageant.contestants.find(params[:id])

    if @contestant.update_attributes(params[:contestant])
      flash[:notice] = "Contestant #{@contestant.name} was successfully updated."
      redirect_to pageant_url(@pageant)
    else
      render :action => "edit"
    end
  end

  def destroy
    @contestant = @pageant.contestants.find(params[:id])
    @contestant.destroy

    redirect_to pageant_url(@pageant)
  end
  
  def sort
    pageant_id = params[:pageant_id]
    params["pageant_#{pageant_id}_contestants"].each_with_index do |id, index|
      Contestant.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
  
private 
  
  def find_pageant 
      @pageant_id = params[:pageant_id] 
      return(redirect_to(pageants_url)) unless @pageant_id 
      @pageant = Pageant.find(@pageant_id) 
  end
  
end
