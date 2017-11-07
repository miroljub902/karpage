class AddRelatableToHashtagUses < ActiveRecord::Migration[5.1]
  def change
    add_reference :hashtag_uses, :relatable, polymorphic: true

    reversible do |dir|
      dir.up do
        HashtagUse.includes(:taggable).each do |use|
          use.relatable = use.taggable.commentable if use.taggable_type == 'Comment'
          use.save!
        end
      end
    end
  end
end
