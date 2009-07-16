class JudgesController < ApplicationController
  layout "default", :except => [ :report ]
  skip_before_filter :authorize_admin, :only => [:record_scores]
  before_filter :find_pageant
  before_filter :authorize_judge_or_admin, :only => [:record_scores]

  def show
    @judge = @pageant.judges.find(params[:id])
    @rounds = @pageant.rounds.find(:all, :conditions=>"manual='f'")
    @contestants = @pageant.contestants.find(:all)
    @judge_rankings = Score.judge_rankings(@judge)
    
    session[:return_to] = request.request_uri
  end
  
  def record_scores
    @judge = @pageant.judges.find(params[:id])
    @rounds = @pageant.rounds.find(:all, :conditions => ["manual = 'f'"])
    @contestants = @pageant.contestants.find(:all)
    @judge_rankings = Score.judge_rankings(@judge)
  end

  def new
    @judge = Judge.new
  end

  def edit
    @judge = @pageant.judges.find(params[:id])
  end

  def create
    @judge = Judge.new(params[:judge])
    @judge.rounds = Round.find(params[:round_ids]) if params[:round_ids]

    if @pageant.judges << @judge
      flash[:notice] = "Judge #{@judge.username} was successfully created."
      redirect_to pageant_url(@pageant)
    else
      render :action => "new"
    end
  end

  def update
    @judge = @pageant.judges.find(params[:id])

    if @judge.update_attributes(params[:judge])
      flash[:notice] = "Judge #{@judge.username} was successfully updated."
      redirect_to pageant_url(@pageant)
    else
      render :action => "edit"
    end
  end

  def destroy
    @judge = @pageant.judges.find(params[:id])
    @judge.destroy

    redirect_to pageant_url(@pageant)
   end
  
  def report
    @judge = @pageant.judges.find(params[:id])
    @rounds = @pageant.rounds.find(:all, :conditions => ["manual = 'f'"])
    @contestants = @pageant.contestants.find(:all, :order=>'position')
    @title = "#{@pageant.title} - #{@judge.alias} Results #{"(incomplete)" if not Score.scoring_locked_for_judge?(@judge) }"
    @headers = []
    @headers << "Contestant" 
    @headers.concat(@rounds.collect {|r| "#{r.abbreviation} (#{r.max_score})"})
    @headers << "Total"
    @data = []
    rankings = Score.rankings(@pageant)
    judge_rankings = Score.judge_rankings(@judge)
    for c in @contestants
      row = []
      row << c.position
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
    prawnto :prawn=>{:page_size=>'A4', :page_layout => :landscape, :left_margin=>72, :right_margin=>72, :top_margin=>72, :bottom_margin=>72 }, :inline=>true, :filename => "#{@judge.alias} Results"
  end
  
  private 
  
  def find_pageant 
      @pageant_id = params[:pageant_id] 
      return(redirect_to(pageants_url)) unless @pageant_id 
      @pageant = Pageant.find(@pageant_id) 
  end
  
end
