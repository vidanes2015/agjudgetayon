class ScoresController < ApplicationController
  layout "default", :except => [ :report, :simple_report ]
  
  skip_before_filter :authorize_admin, :only => [:add_score, :lock_scores, :find_pageant]
  before_filter :authorize_judge_or_admin, :only => [:add_score, :lock_scores, :find_pageant]
  before_filter :find_pageant

  def index
    @contestants = @pageant.contestants.find(:all, :order=>'position')
    @judges = @pageant.judges.find(:all, :order=>'alias')
    @rounds = @pageant.rounds.find(:all, :order=>'position')
    @scores = @pageant.scores.find(:all, :order => "contestant_id, round_id, judge_id")
    @rankings = Score.rankings(@pageant)
    @round_rankings = Hash.new 
    @rounds.each {|r| @round_rankings[r.id] = Score.round_rankings(r)}
    @judge_rankings = Hash.new
    @judges.each {|j| @judge_rankings[j.id] = Score.judge_rankings(j)}
    
    session[:return_to] = request.request_uri 
  end
  
  def new
    @score = Score.new
  end

  def edit
    @score = Score.find(params[:id])
  end

  def create
    @score = Score.new(params[:score])
    if @score.round.manual
      @score.locked = true    
      @score.judge = nil 
    end
    if @pageant.scores << @score
      flash[:notice] = 'Score was successfully created.'
      redirect_to(pageant_scores_url)
    else
      render :action => "new"
    end
  end
  
  def add_score
    pageant_id = params[:pageant_id]
    judge_id = params[:judge_id]
    round_id = params[:round_id]
    contestant_id = params[:contestant_id]
    value = params[:value]
    @score = Score.find_by_pageant_id_and_judge_id_and_contestant_id_and_round_id(pageant_id, judge_id, contestant_id, round_id)
    @score.destroy if @score
    @score = Score.new(:pageant_id=>pageant_id, :judge_id=>judge_id, :round_id=>round_id, :contestant_id=>contestant_id, :value=>value, :locked=>false)
    @score.save
    @contestants = Contestant.find(:all)
    @judge_rankings = Score.judge_rankings(@score.judge)
    respond_to do |format|
      format.js
    end
  end
  
  def lock_scores
    @judge = @pageant.judges.find(params[:judge_id])
    @round = @pageant.rounds.find(params[:round_id])
    if Score.scoring_complete_for_round_and_judge?(@round, @judge)
      Score.find_all_by_round_id_and_judge_id(@round.id, @judge.id).each do |s|
        s.locked = true
        s.save
      end
      redirect_to(record_scores_pageant_judge_url(@pageant, :id=>params[:judge_id])  )
    else
      flash[:notice] = 'You must first provide valid scores for all contestants.'
      redirect_to(record_scores_pageant_judge_url(@pageant, :id=>params[:judge_id])  )
    end
  end
      
  def update
    @score = @pageant.scores.find(params[:id])

    if @score.update_attributes(params[:score])
      flash[:notice] = 'Score was successfully updated.'
      redirect_to(session[:return_to])
    else
      render :action => "edit"
    end
  end

  def destroy
    @score = @pageant.scores.find(params[:id])
    @score.destroy

    redirect_to(session[:return_to])
  end
  
  def destroy_all
    if params[:judge_id]
      scores = @pageant.scores.find_all_by_judge_id(params[:judge_id])
      scores.each {|s| s.destroy}
    elsif params[:round_id]
      scores = @pageant.scores.find_all_by_round_id(params[:round_id])
      scores.each {|s| s.destroy}
    elsif params[:contestant_id]
      scores = @pageant.scores.find_all_by_contestant_id(params[:contestant_id])
      scores.each {|s| s.destroy}
    else
      @pageant.scores.destroy_all
    end

    redirect_to(session[:return_to])
  end
  
  def simple_report
    @judges = @pageant.judges
    @rounds = @pageant.rounds.find(:all, :order=>'position')
    @manual_rounds = @pageant.rounds.find(:all, :conditions=>["manual='t'"])
    @contestants = @pageant.contestants.find(:all, :order=>'position')
    @title = "#{@pageant.title} - Overall Results #{'(incomplete)' if not Score.scoring_locked?(@pageant)}"
    @headers = []
    @headers << ""
    @headers.concat @judges.collect {|j| "#{j.alias}" }
    @headers << "Average"
    if @manual_rounds.size > 0
      @headers << "Manual" << "Total"
    end
    rankings = Score.rankings(@pageant)
    round_rankings = Hash.new 
    @rounds.each {|r| round_rankings[r.id] = Score.round_rankings(r)}
    judge_rankings = Hash.new
    @judges.each {|j| judge_rankings[j.id] = Score.judge_rankings(j)}
    @data = []
    @contestants.each do |c|
      row = []
      row << c.position
      row.concat @judges.collect{|j| sprintf("%.2f (%i)", Score.judge_total_for_contestant(j, c), judge_rankings[j.id][c.id]) }
      if @manual_rounds.size > 0
        manual_total = 0;
        @manual_rounds.each {|r| manual_total += Score.round_average_for_contestant(r, c)}
        row << sprintf("%.2f", Score.score_for_contestant(c)-manual_total, rankings[c.id])
        row << sprintf("%.2f", manual_total)
        row << sprintf("%.2f (%i)", Score.score_for_contestant(c), rankings[c.id])
      else
        row << sprintf("%.2f (%i)", Score.score_for_contestant(c), rankings[c.id])
      end
      @data << row
    end
    prawnto :prawn=>{:page_size=>'A4', :page_layout => :landscape, :left_margin=>72, :right_margin=>72, :top_margin=>72, :bottom_margin=>72 }, :inline=>true, :filename => "Overall Results"
    
  end
  
  def report
    @judges = @pageant.judges.find(:all, :order=>'alias')
    @rounds = @pageant.rounds.find(:all, :order=>'position')
    @contestants = @pageant.contestants.find(:all, :order=>'position')
    @title = "#{@pageant.title} - Detailed Results #{'(incomplete)' if not Score.scoring_locked?(@pageant)}"
    @headers = []
    @headers << "" << @rounds.collect {|r| "#{r.abbreviation} (#{r.max_score})"} << "Total"
    @headers.flatten!
    @data = []
    rankings = Score.rankings(@pageant)
    round_rankings = Hash.new 
    @rounds.each {|r| round_rankings[r.id] = Score.round_rankings(r)}
    judge_rankings = Hash.new
    @judges.each {|j| judge_rankings[j.id] = Score.judge_rankings(j)}
    for c in @contestants
      @data << ["Contestant #{c.position}"].concat(Array.new(Round.count+1, "")) 
      for j in @judges
        row = []
        row << "    #{j.alias}"
        for r in @rounds
          s = Score.find_by_round_id_and_judge_id_and_contestant_id(r.id, j.id, c.id)
          if s and not s.locked
            row << sprintf("*%.2f", s.value)
          elsif s
            row << sprintf("%.2f", s.value)
          else
            row << "---"
          end
        end
        row << sprintf("%.2f (%i)", Score.judge_total_for_contestant(j, c), judge_rankings[j.id][c.id])      
        @data << row
      end
      row = ["    Average"]
      for r in @rounds
        row << sprintf("%.2f (%i)", Score.round_average_for_contestant(r, c), round_rankings[r.id][c.id])
      end
      row << sprintf("%.2f (%i)", Score.score_for_contestant(c), rankings[c.id])
      @data << row
    end
    prawnto :prawn=>{:page_size=>'A4', :page_layout => :landscape, :left_margin=>72, :right_margin=>72, :top_margin=>72, :bottom_margin=>72 }, :inline=>true, :filename => "Complete Overall Results"
  end
  
  private 
  
  def find_pageant 
    @pageant_id = params[:pageant_id] 
    return(redirect_to(pageants_url)) unless @pageant_id 
    @pageant = Pageant.find(@pageant_id) 
  end
  
end
