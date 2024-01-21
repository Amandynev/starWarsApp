# frozen_string_literal: true

json.extract! film, :id, :title, :characters_id, :created_at, :updated_at
json.url film_url(film, format: :json)
