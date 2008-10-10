class JudgesController < ApplicationController
  layout "default", :except => [ :report ]
  skip_before_filter :authorize_admin, :only => [:record_scores]
  before_filter :authorize_judge_or_admin, :only => [:record_scores]

  # GET /judges
  # GET /judges.xml
  def index
    @judges = Judge.find(:all, :order => 'alias')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @judges }
    end
  end

  # GET /judges/1
  # GET /judges/1.xml
  def show
    @judge = Judge.find(params[:id])
    @rounds = @judge.rounds #Round.find(:all, :order => "ordering")
    @contestants = Contestant.find(:all, :order => "number")
    @judge_rankings = Score.judge_rankings(@judge)
    
    session[:return_to] = request.request_uri

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @judge }
    end
  end
  
  def record_scores
    @judge = Judge.find(params[:id])
    @rounds = @judge.rounds #Round.find(:all, :order => "ordering")
    @contestants = Contestant.find(:all, :order => "number")
    @judge_rankings = Score.judge_rankings(@judge)

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /judges/new
  # GET /judges/new.xml
  def new
    @judge = Judge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @judge }
    end
  end

  # GET /judges/1/edit
  def edit
    @judge = Judge.find(params[:id])
  end

  # POST /judges
  # POST /judges.xml
  def create
    @judge = Judge.new(params[:judge])
    @judge.rounds = Round.find(params[:round_ids]) if params[:round_ids]

    respond_to do |format|
      if @judge.save
        flash[:notice] = "Judge #{@judge.username} was successfully created."
        format.html { redirect_to(judges_url) }
        format.xml  { render :xml => @judge, :status => :created, :location => @judge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @judge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /judges/1
  # PUT /judges/1.xml
  def update
    @judge = Judge.find(params[:id])
    @judge.rounds = Round.find(params[:round_ids]) if params[:round_ids]

    respond_to do |format|
      if @judge.update_attributes(params[:judge])
        flash[:notice] = "Judge #{@judge.username} was successfully updated."
        format.html { redirect_to(judges_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @judge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /judges/1
  # DELETE /judges/1.xml
  def destroy
    @judge = Judge.find(params[:id])
    @judge.scores.each { |s| s.destroy }
    @judge.destroy

    respond_to do |format|
      format.html { redirect_to(judges_url) }
      format.xml  { head :ok }
    end
  end
  
  def report
    @judge = Judge.find(params[:id])
    @rounds = @judge.rounds
    @contestants = Contestant.find(:all, :order=>'number')
    @title = "#{@@pageant_title} - #{@judge.alias} Results #{"(incomplete)" if not Score.scoring_locked_for_judge?(@judge) }"
    @headers = []
    @headers << "Contestant" 
    @headers.concat(@rounds.collect {|r| "#{r.abbreviation} (#{r.max_score})"})
    @headers << "Total"
    @data = []
    rankings = Score.rankings()
    judge_rankings = Score.judge_rankings(@judge)
    for c in @contestants
      row = []
      row << c.number
      for r in @rounds
        s = Score.find_by_round_id_and_judge_id_and_contestant_id(r.id, @judge.id, c.id)
        if s and not s.locked
          row << sprintf("*%.2f", s.value)
        elsif s
          row << sprintf("%.2f", s.value)
        else
          row << "---"
        end
      end
      row << sprintf("%.2f (%i)", Score.judge_total_for_contestant(@judge, c), judge_rankings[c.id])
      @data << row
    end
    prawnto :prawn=>{:page_size=>'A4', :page_layout => :landscape, :left_margin=>72, :right_margin=>72, :top_margin=>72, :bottom_margin=>72 }, :inline=>false, :filename => "#{@judge.alias} Results"
  end
  
end
