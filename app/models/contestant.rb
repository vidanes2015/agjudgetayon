class Contestant < ActiveRecord::Base
  has_many :scores
  
  validates_presence_of :number, :name
  validates_numericality_of :number, :only_integer => true, :greater_than => 0
  validates_uniqueness_of :number

end
