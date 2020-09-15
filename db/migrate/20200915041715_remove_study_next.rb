class RemoveStudyNext < ActiveRecord::Migration[6.0]
  def change
    remove_column :card_decks, :next_review_at
  end
end
