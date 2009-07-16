class RoundsController < ApplicationController
  layout "default", :except => [ :report ]
  
  before_filter :find_pageant

  def show
    @round = @pageant.rounds.find(params[:id])
    @contestants = @pageant.contestants.find(:all, :order=>"position")
    @judges = @pageant.judges.find(:all, :order=>"alias")
    @round_rankings = Score.round_rankings(@round)
    session[:return_to] = request.request_uri
  end

  def new
    @round = Round.new
  end

  def edit
    @round = @pageant.rounds.find(params[:id])
  end

  def create
    @round = Round.new(params[:round])

    if @pageant.rounds << @round
      flash[:notice] = "Round #{@round.description} was successfully created."
      redirect_to pageant_url(@pageant)
    else
      render :action => "new"
    end
  end

  def update
    @round = @pageant.rounds.find(params[:id])

    if @round.update_attributes(params[:round])
      flash[:notice] = "Round #{@round.description} was successfully updated."
      redirect_to pageant_url(@pageant)
    else
      render :action => "edit"
    end
  end

  def destroy
    @round = @pageant.rounds.find(params[:id])
    @round.destroy
    
    redirect_to pageant_url(@pageant)
  end
  
  def report
    @round = @pageant.rounds.find(params[:id])
    @judges = @pageant.judges
    @contestants = @pageant.contestants.find(:all, :order=>'position')
    @title = "#{@pageant.title} - #{@round.description} Results (#{@round.max_score}) #{"(incomplete)" if not Score.scoring_locked_for_round?(@round) }"
    @headers = []
    @headers << "Contestant" << @judges.collect {|j| j.alias} << "Average"
    @headers.flatten!
    @data = []
    round_rankings = Score.round_rankings(@round)
    for c in @contestants
      row = []
      row << c.position
      for j in @judges
        s = Score.find_by_round_id_and_judge_id_and_contestant_id(@round.id, j.id, c.id)
        if s and not s.locked
          row << sprintf("*%.2f", s.value)
        elsif s
          row << sprintf("%.2f", s.value)
        else
          row << "---"
        end
      end
      row << sprintf("%.2f (%i)", Score.round_average_for_contestant(@round, c), round_rankings[c.id])
      @data << row
    end
    prawnto :prawn=>{:page_size=>'A4', :page_layout => :landscape, :left_margin=>72, :right_margin=>72, :top_margin=>72, :bottom_margin=>72 }, :inline=>true, :filename => "#{@round.description} Results"
  end

  def sort
    pageant_id = params[:pageant_id]
    params["pageant_#{pageant_id}_rounds"].each_with_index do |id, index|
      Round.update_all(['position=?', index+1], ['id=?', id])
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
