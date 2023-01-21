# frozen_string_literal: true

require_relative 'checks'
require_relative 'checks_extend'
require 'set'

module Checks
  # This is a Jekyll Generator
  class CheckPresInfo < Jekyll::Generator
    # Main entry point for Jekyll
    def generate(site)
      @site = site

      # @site.collections['collaborators'].docs.each do |name, person_hash|
      @site.collections['collaborators'].docs.each do |mydoc|
        # print person_hash
        # print person_hash['name']
        print mydoc
        print mydoc.data['name']
        presentations = mydoc.data['presentations']

        presentations&.each_with_index do |pres_hash, index|
          # msg = "presentation ##{index} in _data/people/#{mydoc.data['shortname']}.yml"
          msg = " presentation ##{index} for #{mydoc.data['name']}"

          ensure_array(presentations[index], 'focus-area')
          ensure_array(presentations[index], 'project')

          local_fa = pres_hash['focus-area']&.to_set
          projectless = site.config['iris-hep']['projectless-focus-areas'].to_set

          presentation = Record.new(msg, pres_hash)
          presentation.key 'title', :nonempty
          presentation.key 'date', :nonempty, :date
          presentation.key 'meeting', :nonempty
          presentation.key 'url'
          presentation.key 'meetingurl', :optional
          presentation.key 'location', :optional
          presentation.key 'focus-area', :optional, set: focus_areas
          presentation.key 'project', :optional, set: projects unless local_fa && local_fa < projectless

          presentation.print_warnings

          # Add the member shortname to every presentation
          presentations[index]['member'] = mydoc.data['shortname']
        end
      end

      @site.data['sorted_presentations'] = get_presentations site.collections['collaborators']
    end

    private

    include IrisHep::GetInfoForChecks

    def get_presentations(people)
      presentations = people.docs.flat_map { |_, p| p['presentations'] || [] }
      presentations.sort_by { |p| p['date'] }.reverse!
    end
  end
end
