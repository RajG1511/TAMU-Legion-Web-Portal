# Events whose end time has passed the current time will be deleted from the database/view
namespace :events do
  desc "Delete events whose end time has passed"
  task cleanup_expired: :environment do
    expired_events = Event.where("ends_at < ?", Time.current)
    count = expired_events.count

    expired_events.find_each do |event|
      puts "Deleting expired event: #{event.name} (ended at #{event.ends_at})"
      event.destroy
    end

    puts "Deleted #{count} expired events."
  end
end
