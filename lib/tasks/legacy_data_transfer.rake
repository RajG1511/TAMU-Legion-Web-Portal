# lib/tasks/legacy_data.rake
namespace :legacy_data do
  desc "Transfer legacy data into new Heroku database"
  task transfer: :environment do
    puts "🚀 Starting legacy data transfer..."
    start_time = Time.current

    begin
      # === USERS ===
      old_users = OldSystem::User.all
      migrated_users = 0
      old_users.find_each do |old|
        user = User.find_or_initialize_by(email: old.email)
        user.assign_attributes(
          first_name: old.first_name,
          last_name: old.last_name,
          graduation_year: old.graduation_year,
          major: old.major,
          t_shirt_size: old.t_shirt_size,
          status: old.status,
          position: old.position,
          role: old.role,
          encrypted_password: old.encrypted_password
        )
        migrated_users += 1 if user.save
      end
      puts "✅ Users migrated: #{migrated_users}"

      # === COMMITTEES ===
      old_committees = OldSystem::Committee.all
      migrated_committees = 0
      old_committees.find_each do |old|
        committee = Committee.find_or_initialize_by(name: old.name)
        committee.description = old.description
        migrated_committees += 1 if committee.save
      end
      puts "✅ Committees migrated: #{migrated_committees}"

      # === COMMITTEE MEMBERSHIPS ===
      old_memberships = OldSystem::CommitteeMembership.all
      migrated_memberships = 0
      old_memberships.find_each do |old|
        user = User.find_by(email: old.user.email)
        committee = Committee.find_by(name: old.committee.name)
        if user && committee
          CommitteeMembership.find_or_create_by!(user: user, committee: committee)
          migrated_memberships += 1
        end
      end
      puts "✅ Committee memberships migrated: #{migrated_memberships}"

      # === EVENTS ===
      migrated_events = 0
      OldSystem::Event.find_each do |old|
        category = EventCategory.find_or_create_by!(name: old.event_category.name)
        event = Event.find_or_initialize_by(name: old.name)
        event.assign_attributes(
          description: old.description,
          starts_at: old.starts_at,
          ends_at: old.ends_at,
          location: old.location,
          event_category: category,
          visibility: old.visibility,
          published: old.published
        )
        migrated_events += 1 if event.save
      end
      puts "✅ Events migrated: #{migrated_events}"

      # === RESOURCES ===
      migrated_resources = 0
      OldSystem::Resource.find_each do |old|
        category = ResourceCategory.find_or_create_by!(name: old.resource_category.name)
        resource = Resource.find_or_initialize_by(name: old.name)
        resource.assign_attributes(
          content: old.content,
          visibility: old.visibility,
          resource_category: category,
          published: old.published,
          resource_type: old.resource_type
        )
        migrated_resources += 1 if resource.save
      end
      puts "✅ Resources migrated: #{migrated_resources}"

      # === SERVICES ===
      migrated_services = 0
      OldSystem::Service.find_each do |old|
        user = User.find_by(email: old.user.email)
        next unless user
        service = Service.find_or_initialize_by(user: user, name: old.name)
        service.assign_attributes(
          hours: old.hours,
          description: old.description,
          date_performed: old.date_performed,
          status: old.status,
          committee: old.committee,
          rejection_reason: old.rejection_reason
        )
        migrated_services += 1 if service.save
      end
      puts "✅ Services migrated: #{migrated_services}"

      # === LOG ===
      MigrationLog.create!(
        table_name: "users, committees, memberships, events, resources, services",
        records_migrated: migrated_users + migrated_committees + migrated_memberships + migrated_events + migrated_resources + migrated_services,
        migrated_at: Time.current,
        notes: "Full legacy data migration successful"
      )

      puts "🎉 Migration complete in #{(Time.current - start_time).round(2)} seconds!"

    rescue => e
      puts "❌ Migration failed: #{e.message}"
      MigrationLog.create!(
        table_name: "unknown",
        records_migrated: 0,
        migrated_at: Time.current,
        notes: "Migration failed: #{e.message}"
      )
      raise e
    end
  end
end
