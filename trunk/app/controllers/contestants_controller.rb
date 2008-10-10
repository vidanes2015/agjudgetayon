class ContestantsController < ApplicationController
  # GET /contestants
  # GET /contestants.xml
  def index
    @contestants = Contestant.find(:all, :order => 'number')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contestants }
    end
  end

  # GET /contestants/1
  # GET /contestants/1.xml
  def show
    @contestant = Contestant.find(params[:id])
    @rounds = Round.find(:all, :order=>'ordering')
    @judges = Judge.find(:all, :order=>'alias')
    @ranking = Score.rankings[@contestant.id]
    @round_rankings = Hash.new
    @rounds.each {|r| @round_rankings[r.id] = Score.round_rankings(r)[@contestant.id]}
    @judge_rankings = Hash.new
    @judges.each {|j| @judge_rankings[j.id] = Score.judge_rankings(j)[@contestant.id]}

    session[:return_to] = request.request_uri

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contestant }
    end
  end

  # GET /contestants/new
  # GET /contestants/new.xml
  def new
    @contestant = Contestant.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contestant }
    end
  end

  # GET /contestants/1/edit
  def edit
    @contestant = Contestant.find(params[:id])
  end

  # POST /contestants
  # POST /contestants.xml
  def create
    @contestant = Contestant.new(params[:contestant])

    respond_to do |format|
      if @contestant.save
        flash[:notice] = "Contestant #{@contestant.number} was successfully created."
        format.html { redirect_to(contestants_url) }
        format.xml  { render :xml => @contestant, :status => :created, :location => @contestant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contestant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contestants/1
  # PUT /contestants/1.xml
  def update
    @contestant = Contestant.find(params[:id])

    respond_to do |format|
      if @contestant.update_attributes(params[:contestant])
        flash[:notice] = "Contestant #{@contestant.number} was successfully updated."
        format.html { redirect_to(contestants_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contestant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contestants/1
  # DELETE /contestants/1.xml
  def destroy
    @contestant = Contestant.find(params[:id])
    @contestant.scores.each { |s| s.destroy }
    @contestant.destroy

    respond_to do |format|
      format.html { redirect_to(contestants_url) }
      format.xml  { head :ok }
    end
  end
end
