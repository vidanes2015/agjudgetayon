class ScoresController < ApplicationController
  layout "default", :except => [ :report, :simple_report ]
  
  skip_before_filter :authorize_admin, :only => [:add_score, :lock_scores]
  before_filter :authorize_add_score, :only => [:add_score]
  before_filter :authorize_lock_scores, :only => [:lock_scores]

  # GET /scores
  # GET /scores.xml
  def index
    @contestants = Contestant.find(:all, :order=>'number')
    @judges = Judge.find(:all, :order=>'alias')
    @rounds = Round.find(:all, :order=>'ordering')
    @scores = Score.find(:all, :order => "contestant_id, round_id, judge_id")
    @rankings = Score.rankings
    @round_rankings = Hash.new 
    @rounds.each {|r| @round_rankings[r.id] = Score.round_rankings(r)}
    @judge_rankings = Hash.new
    @judges.each {|j| @judge_rankings[j.id] = Score.judge_rankings(j)}
    @judge_groupings = Round.judge_groupings
    
    session[:return_to] = request.request_uri 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scores }
    end
  end
  
  # GET /scores/new
  # GET /scores/new.xml
  def new
    @score = Score.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @score }
    end
  end

  # GET /scores/1/edit
  def edit
    @score = Score.find(params[:id])
  end

  # POST /scores
  # POST /scores.xml
  def create
    @score = Score.new(params[:score])

    respond_to do |format|
      if @score.save
        flash[:notice] = 'Score was successfully created.'
        format.html { redirect_to(scores_url) }
        format.xml  { render :xml => @score, :status => :created, :location => @score }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @score.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def add_score
    judge_id = params[:judge_id]
    round_id = params[:round_id]
    contestant_id = params[:contestant_id]
    value = params[:value]
    @score = Score.find_by_judge_id_and_contestant_id_and_round_id(judge_id, contestant_id, round_id)
    @score.destroy if @score
    @score = Score.new(:judge_id=>judge_id, :round_id=>round_id, :contestant_id=>contestant_id, :value=>value, :locked=>false)
    @score.save
    @contestants = Contestant.find(:all)
    @judge_rankings = Score.judge_rankings(@score.judge)
    respond_to do |format|
      format.js
    end
  end
  
  def lock_scores
    @judge = Judge.find(params[:judge_id])
    @round = Round.find(params[:round_id])
    if Score.scoring_complete_for_round_and_judge?(@round, @judge)
      Score.find_all_by_round_id_and_judge_id(@round.id, @judge.id).each do |s|
        s.locked = true
        s.save
      end
    else
      flash[:notice] = 'You must first provide valid scores for all contestants.'
    end
    redirect_to(record_scores_judge_url(:id=>params[:judge_id])  )
  end
      

  # PUT /scores/1
  # PUT /scores/1.xml
  def update
    @score = Score.find(params[:id])

    respond_to do |format|
      if @score.update_attributes(params[:score])
        flash[:notice] = 'Score was successfully updated.'
        format.html { redirect_to(session[:return_to]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scores/1
  # DELETE /scores/1.xml
  def destroy
    @score = Score.find(params[:id])
    @score.destroy

    respond_to do |format|
      format.html { redirect_to(session[:return_to]) }
      format.xml  { head :ok }
    end
  end
  
  
  # DELETE /scores/1
  # DELETE /scores/1.xml
  def destroy_all
    if params[:judge_id]
      scores = Score.find_all_by_judge_id(params[:judge_id])
      scores.each {|s| s.destroy}
    elsif params[:round_id]
      scores = Score.find_all_by_round_id(params[:round_id])
      scores.each {|s| s.destroy}
    elsif params[:contestant_id]
      scores = Score.find_all_by_contestant_id(params[:contestant_id])
      scores.each {|s| s.destroy}
    else
      Score.destroy_all
    end

    respond_to do |format|
      format.html { redirect_to(session[:return_to]) }
      format.xml  { head :ok }
    end
  end
  
  def simple_report
    @judges = params[:judges].collect!{|j| Judge.find(j)} #Judge.find(:all, :order=>'alias')
    @other_judges = Judge.find(:all) - @judges
    @rounds = Round.find(:all, :order=>'ordering')
    @contestants = Contestant.find(:all, :order=>'number')
    @title = "#{@@pageant_title} - Overall Results #{'(incomplete)' if not Score.scoring_locked?}"
    @headers = []
    @headers << ""
    @headers.concat @judges.collect {|j| "#{j.alias}" }
    @headers << "Average" << "Other Judges" << "Total"
    rankings = Score.rankings
    round_rankings = Hash.new 
    @rounds.each {|r| round_rankings[r.id] = Score.round_rankings(r)}
    judge_rankings = Hash.new
    @judges.each {|j| judge_rankings[j.id] = Score.judge_rankings(j)}
    @data = []
    @contestants.each do |c|
      row = []
      row << c.number
      row.concat @judges.collect{|j| sprintf("%.2f (%i)", Score.judge_total_for_contestant(j, c), judge_rankings[j.id][c.id]) }
      row << sprintf("%.2f", Score.judge_group_average_for_contestant(@judges, c))
      row << sprintf("%.2f", Score.judge_group_average_for_contestant(@other_judges, c))
      row << sprintf("%.2f (%i)", Score.score_for_contestant(c), rankings[c.id])
      @data << row
    end
    prawnto :prawn=>{:page_size=>'A4', :page_layout => :landscape, :left_margin=>72, :right_margin=>72, :top_margin=>72, :bottom_margin=>72 }, :inline=>true, :filename => "Overall Results"
    
  end
  
  def report
    @judges = Judge.find(:all, :order=>'alias')
    @rounds = Round.find(:all, :order=>'ordering')
    @contestants = Contestant.find(:all, :order=>'number')
    @title = "#{@@pageant_title} - Detailed Results #{'(incomplete)' if not Score.scoring_locked?}"
#    @row_colors = Array.new(Round.count, "ffffff").concat(["aaaaaa"])
#    @row_colors << "ffffff"
    @headers = []
    @headers << "" << @rounds.collect {|r| "#{r.abbreviation} (#{r.max_score})"} << "Total"
    @headers.flatten!
    @data = []
    rankings = Score.rankings
    round_rankings = Hash.new 
    @rounds.each {|r| round_rankings[r.id] = Score.round_rankings(r)}
    judge_rankings = Hash.new
    @judges.each {|j| judge_rankings[j.id] = Score.judge_rankings(j)}
    for c in @contestants
      @data << ["Contestant #{c.number}"].concat(Array.new(Round.count+1, "")) 
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
    prawnto :prawn=>{:page_size=>'A4', :page_layout => :landscape, :left_margin=>72, :right_margin=>72, :top_margin=>72, :bottom_margin=>72 }, :inline=>false, :filename => "Complete Overall Results"
  end
  
end
