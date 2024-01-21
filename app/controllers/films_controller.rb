# frozen_string_literal: true

class FilmsController < ApplicationController
  before_action :set_film, only: %i[show]

  MIN_MASS = 75
  def index
    # TODO: stock en cache pour améliorer le temps de chargement et ne pas faire trop de call
      response = HTTParty.get('https://swapi.dev/api/films')
      # TODO: retry after failure
      begin
        data = JSON.parse(response.body)
        films_list = data['results']
        @films = get_film_characters(films_list)
      rescue HTTParty::Error, StandardError
        @films = []
        Rails.logger.error "Erreur lors de la récupération de la liste des films : #{response.code}"
        # TODO: add flash message
      end
  end

  def get_film_characters(films)
    @films_characteres = films.map do |film|
      film_title = film['title']
      characters_lists_urls = film['characters']
      characters = characters_lists_urls.flat_map do |character_url|
        get_characters_with_min_mass(character_url)
      end

      {
        title: film_title,
        characters:
      }
    end
  end

  def get_characters_with_min_mass(character_url)
    character_details = []

    begin
      character = HTTParty.get("#{character_url}?mass=#{MIN_MASS}")

      if character['mass'].to_i >= MIN_MASS
        character_details << {
          name: character['name'],
          mass: character['mass'],
          homeworld: get_homeworld_name(character['homeworld'])
        }
      end
    rescue HTTParty::Error, StandardError => e
      Rails.logger.error "Erreur lors de la récupération des détails du personnage : #{e.message}"
      # TODO: add flash message
    end
    character_details.sort! { |a, b| a[:mass].to_i <=> b[:mass].to_i }

    character_details
  end

  def get_homeworld_name(character_homeworld_url)
    begin
      response = HTTParty.get("#{character_homeworld_url}")
      response['name']
    rescue HTTParty::Error, StandardError => e
      Rails.logger.error "Erreur lors de la récupération du nom de la planète : #{e.message}"
      # TODO: add flash message
    end
  end
end
