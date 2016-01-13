module FeaturedOrdering
  extend ActiveSupport::Concern

  # Internally we store the order value in powers of 10 so it's easier to reorder

  included do
    scope :featured, -> { where.not(featured_order: nil).order(featured_order: :asc) }

    after_save -> {
      if (existing = self.class.where(featured_order: featured_order * 10).where.not(id: id).first)
        # Add 5 to the other item so on reordering it will appear after this one
        existing.update_column :featured_order, (existing.featured_order * 10) + 5
        self.class.reorder_featured
      end
      true
    }, if: :featured_order_changed?

    def featured?
      featured_order.present?
    end

    def toggle_featured!
      value = featured? ? nil : (self.class.maximum(:featured_order) || 0) + 10
      update_column :featured_order, value
      self.class.reorder_featured
    end

    def featured_order
      order = read_attribute(:featured_order)
      order ? order / 10 : order
    end

    def featured_order=(order)
      order = order.to_i.to_s == order ? order.to_i : nil unless order.is_a?(Fixnum)
      write_attribute :featured_order, order * 10
      order
    end

    def self.reorder_featured
      User.featured.each_with_index do |user, order|
        user.update_column :featured_order, (order * 10) + 10
      end
    end
  end
end
