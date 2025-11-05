module UsersHelper
  # Works whether your user_versions has actor_id (association),
  # updated_by (string), or neither (falls back).
  def version_actor_name(v)
    if v.respond_to?(:actor) && v.try(:actor).present?
      v.actor.full_name
    elsif v.respond_to?(:updated_by) && v.try(:updated_by).present?
      v.updated_by
    elsif v.respond_to?(:user) && v.try(:user).present?
      # fallback to the subject user if nothing else was recorded
      v.user.full_name
    else
      "Unknown"
    end
  end

  # Handles enum, string, or missing column gracefully
  def version_change_label(v)
    if v.respond_to?(:change_type) && v.change_type.present?
      v.change_type.to_s.humanize
    elsif v.respond_to?(:action) && v.action.present?
      v.action.to_s.humanize
    else
      "Updated"
    end
  end
end

