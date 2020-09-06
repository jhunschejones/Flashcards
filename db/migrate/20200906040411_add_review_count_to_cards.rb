class AddReviewCountToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :review_count, :bigint, default: 0
  end
end
