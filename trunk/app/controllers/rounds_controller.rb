class RoundsController < ApplicationController
  layout "default", :except => [ :report ]

  # GET /rounds
  # GET /rounds.xml
  def index
    @rounds = Round.find(:all, :order => 'ordering')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rounds }
    end
  end

  # GET /rounds/1
  # GET /rounds/1.xml
  def show
    @round = Round.find(params[:id])
    @contestants = Contestant.find(:all, :order=>"number")
    @judges = @round.judges #Judge.find(:all, :order=>"alias")
    @round_rankings = Score.round_rankings(@round)
    session[:return_to] = request.request_uri

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @round }
    end
  end

  # GET /rounds/new
  # GET /rounds/new.xml
  def new
    @round = Round.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @round }
    end
  end

  # GET /rounds/1/edit
  def edit
    @round = Round.find(params[:id])
  end

  # POST /rounds
  # POST /rounds.xml
  def create
    @round = Round.new(params[:round])
    @round.judges = Judge.find(params[:judge_ids]) if params[:judge_ids]

    respond_to do |format|
      if @round.save
        flash[:notice] = "Round #{@round.description} was successfully created."
        format.html { redirect_to(rounds_url) }
        format.xml  { render :xml => @round, :status => :created, :location => @round }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @round.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rounds/1
  # PUT /rounds/1.xml
  def update
    @round = Round.find(params[:id])
    @round.judges = Judge.find(params[:judge_ids]) if params[:judge_ids]

    respond_to do |format|
      if @round.update_attributes(params[:round])
        flash[:notice] = "Round #{@round.description} was successfully updated."
        format.html { redirect_to(rounds_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @round.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rounds/1
  # DELETE /rounds/1.xml
  def destroy
    @round = Round.find(params[:id])
    @round.scores.each { |s| s.destroy }
    @round.destroy

    respond_to do |format|
      format.html { redirect_to(rounds_url) }
      format.xml  { head :ok }
    end
  end
  
  def report
    @round = Round.find(params[:id])
    @judges = @round.judges #Judge.find(:all, :order=>'alias')
    @contestants = Contestant.find(:all, :order=>'number')
    @title = "#{@@pageant_title} - #{@round.description} Results (#{@round.max_score}) #{"(incomplete)" if not Score.scoring_locked_for_round?(@round) }"
    @headers = []
    @headers << "Contestant" << @judges.collect {|j| j.alias} << "Average"
    @headers.flatten!
    @data = []
    round_rankings = Score.round_rankings(@round)
    for c in @contestants
      row = []
      row << c.number
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
    prawnto :prawn=>{:page_size=>'A4', :page_layout => :landscape, :left_margin=>72, :right_margin=>72, :top_margin=>72, :bottom_margin=>72 }, :inline=>false, :filename => "#{@round.description} Results"
  end
  
end
