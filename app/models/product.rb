class Product < ApplicationRecord
	# validates :name, uniqueness: { case_sensitive: false }
	has_many :items
end