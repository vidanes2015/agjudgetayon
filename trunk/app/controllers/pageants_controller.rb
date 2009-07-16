class PageantsController < ApplicationController
  
  def index
    @pageants = Pageant.all
    redirect_to(@pageants.first) if not @pageants.empty?
  end

  def show
    @pageants = Pageant.all
    @pageant = Pageant.find(params[:id])
  end

  def new
    @pageant = Pageant.new
  end

  def edit
    @pageant = Pageant.find(params[:id])
  end

  def create
    @pageant = Pageant.new(params[:pageant])

    if @pageant.save
      flash[:notice] = 'Pageant was successfully created.'
      redirect_to(@pageant)
    else
      render :action => "new"
    end
  end

  def update
    @pageant = Pageant.find(params[:id])

    if @pageant.update_attributes(params[:pageant])
      flash[:notice] = 'Pageant was successfully updated.'
      redirect_to(@pageant)
    else
      render :action => "edit"
    end
  end

  def destroy
    @pageant = Pageant.find(params[:id])
    @pageant.destroy

    redirect_to(pageants_url)
  end
end
