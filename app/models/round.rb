class Round < ActiveRecord::Base
  has_and_belongs_to_many :judges, :order=>'alias'
  has_many :scores
  
  validates_presence_of :description, :max_score, :ordering, :abbreviation
  validates_uniqueness_of :ordering, :abbreviation
  validates_length_of :abbreviation, :maximum=>8
  validates_numericality_of :max_score, :greater_than => 0
  validates_numericality_of :ordering, :greater_than => 0

  def self.judge_groupings
    groupings = []
    Round.find(:all).each do |r|
      groupings << r.judges unless groupings.include?(r.judges)
    end
    groupings
  end
  
  def self.total_possible_for_judge_grouping(judge_grouping)
    total = 0
    rounds = judge_grouping[0].rounds
    for r in rounds
      total += r.max_score
    end
    total
  end

end
