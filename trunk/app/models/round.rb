class Round < ActiveRecord::Base
  has_many :scores, :dependent => :destroy
  belongs_to :pageant
  
  validates_presence_of :description, :max_score, :abbreviation
  validates_length_of :abbreviation, :maximum=>4
  validates_numericality_of :max_score, :greater_than => 0
    
  acts_as_list :scope => 'pageant_id = #{pageant_id}'
  
end
