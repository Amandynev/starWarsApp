# frozen_string_literal: true

class Film < ApplicationRecord
  has_many :characters
end
