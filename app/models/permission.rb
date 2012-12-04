class Permission < ActiveRecord::Base

  attr_accessible :entity, :action

  validates :entity, :presence => true
  validates :action, :presence => true

end
