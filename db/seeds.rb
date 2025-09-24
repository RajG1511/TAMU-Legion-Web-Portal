# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
puts "Cleaning database..."
Service.destroy_all
CommitteeMembership.destroy_all
Committee.destroy_all
Event.destroy_all
EventCategory.destroy_all
Resource.destroy_all
ResourceCategory.destroy_all
User.destroy_all

puts "Creating users..."
# Create president
president = User.create!(
  email: "president@org.edu",
  first_name: "Joe",
  last_name: "President",
  graduation_year: 2025,
  major: "Computer Science",
  t_shirt_size: "L",
  status: :active,
  role: :president,  # Updated to use president role
  position: "President"
)

# Create exec users
vp = User.create!(
  email: "vp@org.edu",
  first_name: "Jane",
  last_name: "VP",
  graduation_year: 2026,
  major: "Engineering",
  t_shirt_size: "M",
  status: :active,
  role: :exec,
  position: "Vice President"
)

treasurer = User.create!(
  email: "treasurer@org.edu",
  first_name: "Tom",
  last_name: "Treasurer",
  graduation_year: 2025,
  major: "Finance",
  t_shirt_size: "L",
  status: :active,
  role: :exec,
  position: "Treasurer"
)

service_chair = User.create!(
  email: "service@org.edu",
  first_name: "Sarah",
  last_name: "Service",
  graduation_year: 2026,
  major: "Biology",
  t_shirt_size: "S",
  status: :active,
  role: :exec,
  position: "Service Chair"
)

# Create regular members
5.times do |i|
  User.create!(
    email: "member#{i+1}@org.edu",
    first_name: "Member",
    last_name: "#{i+1}",
    graduation_year: 2024 + rand(4),
    major: ["Computer Science", "Engineering", "Business", "Biology"].sample,
    t_shirt_size: %w[S M L XL].sample,
    status: :active,
    role: :member
  )
end

# Create non-members
2.times do |i|
  User.create!(
    email: "nonmember#{i+1}@org.edu",
    first_name: "Guest",
    last_name: "#{i+1}",
    graduation_year: 2024 + rand(4),
    major: ["Computer Science", "Engineering", "Business", "Biology"].sample,
    t_shirt_size: %w[S M L XL].sample,
    status: :active,
    role: :nonmember
  )
end

# Create committees
puts "Creating committees..."
committees = ["Service", "Philanthropy", "PR", "Social", "Brotherhood", "Presidential"].map do |name|
  Committee.create!(name: name, description: "#{name} committee description")
end

# Assign users to committees (only members, execs, and president)
User.where(role: [:member, :exec, :president]).each do |user|
  committees.sample(rand(1..3)).each do |committee|
    CommitteeMembership.create!(user: user, committee: committee)
  end
end

# Create event categories
puts "Creating event categories..."
event_categories = ["Service", "Brotherhood", "Recruitment", "Social"].map do |name|
  EventCategory.create!(name: name)
end

#Create events
puts "Creating events..."
10.times do |i|
  Event.create!(
    name: "Event #{i+1}",
    description: "Description for event #{i+1}",
    starts_at: i.days.from_now,
    ends_at: i.days.from_now + 2.hours,
    location: "Room #{100 + i}",
    location_type: ['campus', 'off_campus'].sample,
    campus_code: ['ZACH', 'HRBB', 'ETB', 'BLOC'].sample,
    campus_number: rand(100..500),
    location_name: "Conference Room #{i+1}",
    address: "123 University Drive, College Station, TX 77840",
    published: [:draft, :published].sample,
    event_category: event_categories.sample,
    visibility: [:public_event, :members_only, :execs_only].sample
  )
end

# Create resource categories
puts "Creating resource categories..."
resource_categories = ["Forms", "Guides", "Policies"].map do |name|
  ResourceCategory.create!(name: name)
end

# Create resources
puts "Creating resources..."
Resource.create!(
  name: "Reimbursement Form",
  content: "Link to Google Form for reimbursements",
  visibility: :members_only,
  resource_category: resource_categories.first
)

Resource.create!(
  name: "Member Handbook",
  content: "Organization member handbook content",
  visibility: :public_resource,
  resource_category: resource_categories.second
)

Resource.create!(
  name: "Executive Guidelines",
  content: "Guidelines for executive board members",
  visibility: :execs_only,
  resource_category: resource_categories.third
)

# Create service hour submissions
puts "Creating service hour submissions..."
User.where(role: [:member, :exec, :president]).each do |user|
  rand(1..3).times do |i|
    Service.create!(
      user: user,
      hours: rand(1.0..5.0).round(1),
      name: "Service Activity #{i+1}",
      description: "Helped with community service",
      date_performed: rand(1..30).days.ago,
      status: [:pending, :approved, :rejected].sample
    )
  end
end

puts "Seeds completed!"
puts "Created #{User.count} users"
puts "  - President: #{User.president.count}"
puts "  - Execs: #{User.exec.count}"
puts "  - Members: #{User.member.count}"
puts "  - Non-members: #{User.nonmember.count}"
puts "Created #{Committee.count} committees"
puts "Created #{Event.count} events"
puts "Created #{Resource.count} resources"
puts "Created #{Service.count} service submissions"
