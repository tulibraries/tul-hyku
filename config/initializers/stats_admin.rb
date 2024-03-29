# frozen_string_literal: true

# -*- coding: utf-8 -*-
module Hyrax
  class StatsAdmin
    def self.matches?(request)
      current_user = request.env['warden'].user
      ::Ability.new(current_user).can?(:manage, Site.instance)
    end
  end
end
