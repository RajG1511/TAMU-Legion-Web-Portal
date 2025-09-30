puts "Seeding…"

# -----------------------------
# USERS
# -----------------------------
def ensure_user!(email:, first:, last:, role:, status: :active, position: nil, grad: 2026, major: "Computer Science", tshirt: "S")
  User.find_or_create_by!(email: email) do |u|
    u.first_name = first
    u.last_name  = last
    u.graduation_year = grad
    u.major = major
    u.t_shirt_size = tshirt
    u.status = status
    u.role = role
    u.position = position
  end
end

# President + devs (president-level)
ensure_user!(email: "president@org.edu", first: "Joe", last: "President", role: :president, position: "President", grad: 2025, tshirt: "L")
[
  ["uzairak12@tamu.edu","Uzair","Khan"],
  ["kylepalermo@tamu.edu","Kyle","Palermo"],
  ["djw9699@tamu.edu","David","Wang"],
  ["raj.gupta@tamu.edu","Raj","Gupta"],
].each { |e,f,l| ensure_user!(email: e, first: f, last: l, role: :president, position: "President") }

# Execs
ensure_user!(email: "vp@org.edu", first: "Jane", last: "VP", role: :exec, position: "Vice President", major: "Engineering", tshirt: "M")
ensure_user!(email: "treasurer@org.edu", first: "Tom", last: "Treasurer", role: :exec, position: "Treasurer", major: "Finance", grad: 2025, tshirt: "L")
ensure_user!(email: "service@org.edu", first: "Sarah", last: "Service", role: :exec, position: "Service Chair", major: "Biology")

# Members
5.times do |i|
  ensure_user!(
    email: "member#{i+1}@org.edu",
    first: "Member", last: (i+1).to_s, role: :member,
    grad: 2024 + rand(4),
    major: ["Computer Science", "Engineering", "Business", "Biology"].sample,
    tshirt: %w[S M L XL].sample
  )
end

# Non-members
2.times do |i|
  ensure_user!(
    email: "nonmember#{i+1}@org.edu",
    first: "Guest", last: (i+1).to_s, role: :nonmember,
    grad: 2024 + rand(4),
    major: ["Computer Science", "Engineering", "Business", "Biology"].sample,
    tshirt: %w[S M L XL].sample
  )
end

# -----------------------------
# COMMITTEES
# -----------------------------
committees = %w[Service Philanthropy PR Social Brotherhood Presidential].map do |name|
  Committee.find_or_create_by!(name: name) { |c| c.description = "#{name} committee description" }
end

# Assign users (members/execs/president only)
User.where(role: [:member, :exec, :president]).find_each do |user|
  committees.sample(rand(1..3)).each do |committee|
    CommitteeMembership.find_or_create_by!(user: user, committee: committee)
  end
end

# -----------------------------
# OPTIONAL: EVENTS/RESOURCES/SERVICES
# Uncomment this block if you want to seed them.
# -----------------------------
=begin
puts "Creating event categories…"
event_categories = ["Service", "Brotherhood", "Recruitment", "Social"].map do |name|
  EventCategory.find_or_create_by!(name: name)
end

puts "Creating events…"
10.times do |i|
  Event.find_or_create_by!(name: "Event #{i+1}") do |e|
    e.description   = "Description for event #{i+1}"
    e.starts_at     = i.days.from_now
    e.ends_at       = i.days.from_now + 2.hours
    e.location      = "Room #{100 + i}"
    e.location_type = ['campus', 'off_campus'].sample
    e.campus_code   = ['ZACH', 'HRBB', 'ETB', 'BLOC'].sample
    e.campus_number = rand(100..500)
    e.location_name = "Conference Room #{i+1}"
    e.address       = "123 University Drive, College Station, TX 77840"
    e.published     = [:draft, :published].sample
    e.event_category= event_categories.sample
    e.visibility    = [:public_event, :members_only, :execs_only].sample
  end
end

puts "Creating resource categories…"
resource_categories = ["Forms", "Guides", "Policies"].map do |name|
  ResourceCategory.find_or_create_by!(name: name)
end

puts "Creating resources…"
Resource.find_or_create_by!(name: "Reimbursement Form") do |r|
  r.content = "Link to Google Form for reimbursements"
  r.visibility = :members_only
  r.resource_category = resource_categories.first
end
Resource.find_or_create_by!(name: "Member Handbook") do |r|
  r.content = "Organization member handbook content"
  r.visibility = :public_resource
  r.resource_category = resource_categories.second
end
Resource.find_or_create_by!(name: "Executive Guidelines") do |r|
  r.content = "Guidelines for executive board members"
  r.visibility = :execs_only
  r.resource_category = resource_categories.third
end

puts "Creating service hour submissions…"
User.where(role: [:member, :exec, :president]).find_each do |user|
  rand(1..3).times do |i|
    Service.find_or_create_by!(user: user, name: "Service Activity #{i+1}") do |s|
      s.hours = rand(1.0..5.0).round(1)
      s.description = "Helped with community service"
      s.date_performed = rand(1..30).days.ago
      s.status = [:pending, :approved, :rejected].sample
    end
  end
end
=end

puts "Done."
puts "Users: #{User.count} (presidents=#{User.where(role: :president).count}, execs=#{User.where(role: :exec).count}, members=#{User.where(role: :member).count}, nonmembers=#{User.where(role: :nonmember).count})"
puts "Committees: #{Committee.count}"
