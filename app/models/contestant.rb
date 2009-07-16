class Contestant < ActiveRecord::Base
  has_many :scores, :dependent => :destroy
  belongs_to :pageant
  
  validates_presence_of :name
  
  acts_as_list :scope => 'pageant_id = #{pageant_id}'

end
