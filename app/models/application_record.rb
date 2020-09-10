class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Using non-bang methods because I need to be able to use this within a
  # transaction without stopping the entire transaction.
  def self.create_if_not_exists(attributes)
    create(attributes) || find_by(attributes)
  end
end
