class Score < ActiveRecord::Base
  belongs_to :contestant
  belongs_to :judge
  belongs_to :round
  
  validates_presence_of :value, :contestant_id, :judge_id, :round_id
  validate :value_less_than_max
  validate :value_numericality_by_regex
  validate :one_score_for_judge_contestant_and_round
  
  
  def self.scoring_locked?
    expected = 0
    Round.find(:all).each do |r|
      expected += r.judges.size
    end
    expected *= Contestant.count
    logger.info("Expected #{expected}")
    logger.info("actual #{Score.count({:conditions => "locked = 't'"})}")
    expected == Score.count({:conditions => "locked = 't'"})
  end
  
  def self.scoring_locked_for_contestant?(contestant)
    expected = 0
    Round.find(:all).each do |r|
      expected += r.judges.size
    end
    expected == Score.count_by_sql("select count(value) from scores where contestant_id = #{contestant.id} and locked = 't'")
  end
  
  def self.scoring_locked_for_round?(round)
    Contestant.count*round.judges.size == Score.count_by_sql("select count(value) from scores where round_id = #{round.id} and locked = 't'")
  end
  
  def self.scoring_locked_for_judge?(judge)
    judge.rounds.size*Contestant.count == Score.count_by_sql("select count(value) from scores where judge_id = #{judge.id} and locked = 't'")
  end
  
  def self.scoring_complete_for_round_and_judge?(round, judge)
    Contestant.count == Score.count_by_sql("select count(value) from scores where judge_id = #{judge.id} and round_id = #{round.id}")
  end
  
  def self.scoring_locked_for_round_and_judge?(round, judge)
    Contestant.count == Score.count_by_sql("select count(value) from scores where judge_id = #{judge.id} and round_id = #{round.id} and locked = 't'")
  end
  
  def self.score_for_contestant(contestant)
    total = 0.0
    for r in Round.find(:all)
      total += round_average_for_contestant(r, contestant) 
    end
    total
  end
  
  def self.judge_group_average_for_contestant(judge_group, contestant)
    total = 0.0
    for j in judge_group
      total += judge_total_for_contestant(j, contestant)
    end
    total/judge_group.size
  end
  
  def self.judge_total_for_contestant(judge, contestant)
    s = Score.calculate(:sum, :value, :conditions => ["contestant_id=? and judge_id = ?", contestant.id, judge.id])
  end
  
  def self.round_average_for_contestant(round, contestant)
    Score.calculate(:avg, :value, :conditions => ["contestant_id=? and round_id = ?", contestant.id, round.id]) || 0.0
  end
  
  def self.rank_hash(values)
    values = values.sort {|a,b| a[1]<=>b[1]}
    values.reverse!
    result = {}
    count = 1
    rank = 1
    prev = values[0][1]
    values.each_index do |i|
      if i>0 and values[i][1]==values[i-1][1]
        result[values[i][0]] = result[values[i-1][0]]
      else
        result[values[i][0]] = i+1
      end
    end
    result
  end
  
  def self.rankings
    data = {}
    Contestant.find(:all).each do |c|
      data[c.id] = Score.score_for_contestant(c)
    end
    self.rank_hash(data)
  end
  
  def self.judge_rankings(judge)
    data = {}
    Contestant.find(:all).each do |c|
      data[c.id] = Score.judge_total_for_contestant(judge, c)
    end
    self.rank_hash(data)
  end
  
  def self.round_rankings(round)
    data = {}
    Contestant.find(:all).each do |c|
      data[c.id] = Score.round_average_for_contestant(round, c)
    end
    self.rank_hash(data)
  end
  
protected

  def value_numericality_by_regex
    if not value_before_type_cast =~ /^\s*\d*\.?\d*\s*$/
      errors.add(:value, "is not a number")
    elsif value.to_f < 1.0
      errors.add(:value, "cannot be less than 1.0")
    end
  end
  
  def value_less_than_max
    max_score = round.max_score
    errors.add(:value, "must be less than #{max_score}") if value.nil? || value > max_score
  end
  
  def one_score_for_judge_contestant_and_round
    other = Score.find_by_judge_id_and_contestant_id_and_round_id(judge_id, contestant_id, round_id)
    if not other.nil? and other.id != id
      errors.add_to_base("Cannot have more than one score for a given judge, contestant, and round")
    end
  end
  
end
