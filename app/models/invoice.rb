class Invoice < ApplicationRecord
    validates :payment_reference, presence: true, uniqueness: true
end
