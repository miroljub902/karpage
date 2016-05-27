class GATracker
  def self.event!(user, category:, action:, label:, value:)
    id = user.try(:id) || SecureRandom.uuid
    tracker = Staccato.tracker(ENV.fetch('GOOGLE_ANALYTICS_ACCOUNT'), id, ssl: true)
    tracker.event category: category, action: action, label: label, value: value
  end
end
