puts "Creating users..."

# President
president = User.create!(
  email: "president@org.edu",
  provider: "google_oauth2",
  uid: "president123",
  first_name: "Joe",
  last_name: "President",
  graduation_year: 2025,
  major: "Computer Science",
  t_shirt_size: "L",
  status: :active,
  role: :president,
  position: "President"
)

# Developer users with president access
dev0 = User.create!(
  email: 'uzairak12@tamu.edu',
  provider: "google_oauth2",
  uid: "uzair123",
  first_name: 'Uzair',
  last_name: 'Khan',
  graduation_year: 2026,
  major: 'Computer Science',
  t_shirt_size: 'S',
  status: :active,
  role: :president,
  position: 'President'
)

dev1 = User.create!(
  email: 'kylepalermo@tamu.edu',
  provider: "google_oauth2",
  uid: "kyle123",
  first_name: 'Kyle',
  last_name: 'Palermo',
  graduation_year: 2026,
  major: 'Computer Science',
  t_shirt_size: 'S',
  status: :active,
  role: :president,
  position: 'President'
)

dev2 = User.create!(
  email: 'djw9699@tamu.edu',
  provider: "google_oauth2",
  uid: "david123",
  first_name: 'David',
  last_name: 'Wang',
  graduation_year: 2026,
  major: 'Computer Science',
  t_shirt_size: 'S',
  status: :active,
  role: :president,
  position: 'President'
)

dev3 = User.create!(
  email: 'raj.gupta@tamu.edu',
  provider: "google_oauth2",
  uid: "raj123",
  first_name: 'Raj',
  last_name: 'Gupta',
  graduation_year: 2026,
  major: 'Computer Science',
  t_shirt_size: 'S',
  status: :active,
  role: :president,
  position: 'President'
)

# Exec users
vp = User.create!(
  email: "vp@org.edu",
  provider: "google_oauth2",
  uid: "vp123",
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
  provider: "google_oauth2",
  uid: "treasurer123",
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
  provider: "google_oauth2",
  uid: "service123",
  first_name: "Sarah",
  last_name: "Service",
  graduation_year: 2026,
  major: "Biology",
  t_shirt_size: "S",
  status: :active,
  role: :exec,
  position: "Service Chair"
)

# Regular members
5.times do |i|
  User.create!(
    email: "member#{i+1}@org.edu",
    provider: "google_oauth2",
    uid: "member#{i+1}",
    first_name: "Member",
    last_name: "#{i+1}",
    graduation_year: 2024 + rand(4),
    major: ["Computer Science", "Engineering", "Business", "Biology"].sample,
    t_shirt_size: %w[S M L XL].sample,
    status: :active,
    role: :member
  )
end

# Non-members
2.times do |i|
  User.create!(
    email: "nonmember#{i+1}@org.edu",
    provider: "google_oauth2",
    uid: "nonmember#{i+1}",
    first_name: "Guest",
    last_name: "#{i+1}",
    graduation_year: 2024 + rand(4),
    major: ["Computer Science", "Engineering", "Business", "Biology"].sample,
    t_shirt_size: %w[S M L XL].sample,
    status: :active,
    role: :nonmember
  )
end

# Committees
puts "Creating committees..."
committees = ["Service", "Philanthropy", "PR", "Social", "Brotherhood", "Presidential"].map do |name|
  Committee.create!(name: name, description: "#{name} committee description")
end

# Assign users to committees
User.where(role: [:member, :exec, :president]).each do |user|
  committees.sample(rand(1..3)).each do |committee|
    CommitteeMembership.create!(user: user, committee: committee)
  end
end

puts "Creating event categories..."
["Service", "Brotherhood", "Recruitment", "Social"].each do |name|
  EventCategory.find_or_create_by!(name: name)
end

puts "Seeds completed!"
puts "Created #{User.count} users"
puts "  - President: #{User.president.count}"
puts "  - Execs: #{User.exec.count}"
puts "  - Members: #{User.member.count}"
puts "  - Non-members: #{User.nonmember.count}"
puts "Created #{Committee.count} committees"