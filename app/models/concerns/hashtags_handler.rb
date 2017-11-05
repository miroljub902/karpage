module HashtagsHandler
  extend ActiveSupport::Concern

  OBSERVABLE_COLUMNS = %w[body description].freeze

  included do
    has_many :hashtag_uses, as: :taggable, dependent: :delete_all
    has_many :hashtags, -> { distinct }, through: :hashtag_uses

    OBSERVABLE_COLUMNS.each do |column|
      if columns_hash.key?(column)
        class_variable_set "@@_hashtags_handler_column", column
        break
      end
    end

    after_save do
      if saved_change_to_attribute?(self.class.class_variable_get('@@_hashtags_handler_column'))
        hashtag_uses.destroy_all
        hashtags.each do |hashtag|
          hashtag_uses.create! hashtag: Hashtag.where(tag: hashtag).first_or_create!
        end
      end
    end
  end

  private

  def hashtags
    test = public_send(self.class.class_variable_get('@@_hashtags_handler_column'))
    test.scan(/\B#([\w-]+)/).flatten
  end
end
