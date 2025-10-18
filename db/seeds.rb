puts "Seeding…"

# -----------------------------
# USERS
# -----------------------------
def ensure_user!(email:, first:, last:, role:, status: :active, position: nil,
                 grad: 2026, major: "Computer Science", tshirt: "S")
  user = User.find_or_initialize_by(email: email)
  user.first_name       = first
  user.last_name        = last
  user.graduation_year  = grad
  user.major            = major
  user.t_shirt_size     = tshirt
  user.status           = status
  user.role             = role
  user.position         = position

  # Always set a password if the user is new or has no valid password
  if user.new_record? || !user.valid_password?(ENV.fetch("DEFAULT_USER_PASSWORD", "changeme123"))
    default_pw = ENV.fetch("DEFAULT_USER_PASSWORD", "changeme123")
    user.password              = default_pw
    user.password_confirmation = default_pw
  end

  user.save!
end

# President + devs (president-level)
ensure_user!(email: "president@org.edu", first: "Joe", last: "President",
             role: :president, position: "President", grad: 2025, tshirt: "L")

[
  ["uzairak12@tamu.edu","Uzair","Khan"],
  ["kylepalermo@tamu.edu","Kyle","Palermo"],
  ["djw9699@tamu.edu","David","Wang"],
  ["raj.gupta@tamu.edu","Raj","Gupta"],
].each do |e,f,l|
  ensure_user!(email: e, first: f, last: l, role: :president, position: "President")
end

# Execs
ensure_user!(email: "vp@org.edu", first: "Jane", last: "VP", role: :exec,
             position: "Vice President", major: "Engineering", tshirt: "M")
ensure_user!(email: "treasurer@org.edu", first: "Tom", last: "Treasurer", role: :exec,
             position: "Treasurer", major: "Finance", grad: 2025, tshirt: "L")
ensure_user!(email: "service@org.edu", first: "Sarah", last: "Service", role: :exec,
             position: "Service Chair", major: "Biology")

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

# Shared user for gallery photos
User.find_or_initialize_by(email: "shared@domain.com").tap do |user|
  user.first_name = "Shared"
  user.last_name  = "User"
  user.role       = "exec"
  user.status     = "active"
  user.password   = ENV.fetch("SHARED_USER_PASSWORD", "defaultpassword")
  user.password_confirmation = user.password
  user.save!
end

# -----------------------------
# COMMITTEES
# -----------------------------
committees = %w[Service Philanthropy PR Social Brotherhood Presidential].map do |name|
  Committee.find_or_create_by!(name: name) do |c|
    c.description = "#{name} committee description"
  end
end

# Assign users (members/execs/president only)
User.where(role: [:member, :exec, :president]).find_each do |user|
  committees.sample(rand(1..3)).each do |committee|
    CommitteeMembership.find_or_create_by!(user: user, committee: committee)
  end
end

puts "Done."
puts "Users: #{User.count} (presidents=#{User.where(role: :president).count}, execs=#{User.where(role: :exec).count}, members=#{User.where(role: :member).count}, nonmembers=#{User.where(role: :nonmember).count})"
puts "Committees: #{Committee.count}"