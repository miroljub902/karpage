module MentionsNotifier
  extend ActiveSupport::Concern

  OBSERVABLE_COLUMNS = %w[body description].freeze

  included do
    OBSERVABLE_COLUMNS.each do |column|
      if columns_hash.key?(column)
        class_variable_set "@@_mentions_notifier_column", column
        break
      end
    end

    after_save do
      if saved_change_to_attribute?(self.class.class_variable_get('@@_mentions_notifier_column'))
        mentions.each do |mention|
          next unless (user = User.find_by(login: mention))
          Notification.belay_create user: user, type: Notification.types[:mention], notifiable: self, source: self.user
        end
      end
    end
  end

  private

  def mentions
    test = public_send(self.class.class_variable_get('@@_mentions_notifier_column'))
    test.scan(/\B@([\w.]+)/).flatten.uniq
  end
end
