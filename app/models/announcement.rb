class Announcement < ApplicationRecord
     # Always work with a single "current" announcement record
     def self.current
          first_or_create
     end
end
