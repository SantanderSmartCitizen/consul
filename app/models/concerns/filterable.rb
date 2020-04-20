module Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_user_profile_city_hall,  -> { where("users.official_level > ?", Setting["last_citizens_official_level"].to_i).joins(:author) }
    scope :by_user_profile_citizen,    -> { where("users.official_level <= ?", Setting["last_citizens_official_level"].to_i).joins(:author) }
    scope :by_official_level,       ->(official_level) { where(users: { official_level: official_level }).joins(:author) }
    scope :by_date_range,           ->(date_range)     { where(created_at: date_range) }
  end

  class_methods do
    def filter(params)
      resources = all
      params.each do |filter, value|
        if allowed_filter?(filter, value)
          if filter == "user_profile"
            if value == "city_hall"
              resources = resources.send("by_user_profile_city_hall")
            elsif value == "citizen"
               resources = resources.send("by_user_profile_citizen")
            end
          else
             resources = resources.send("by_#{filter}", value)
          end
        end
      end
      resources
    end

    def allowed_filter?(filter, value)
      return if value.blank?

      ["user_profile", "official_level", "date_range"].include?(filter)
    end
  end
end
