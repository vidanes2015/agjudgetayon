class Pageant < ActiveRecord::Base
  has_many :rounds, :order => "position", :dependent => :destroy
  has_many :contestants, :order => "position", :dependent => :destroy
  has_many :judges, :dependent => :destroy
  has_many :scores, :dependent => :destroy

  validates_presence_of :title
  validates_uniqueness_of :title
  
  def total_possible
    total = 0
    self.rounds.each do |r|
      total += r.max_score
    end
    total
  end
end
