class Screen < ActiveRecord::Base

  has_many :messages

  # Since we manipulate ID's manually, this is important line
  validates_uniqueness_of :id

end
