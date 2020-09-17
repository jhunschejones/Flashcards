class AddMinimumDifficultyToDeck < ActiveRecord::Migration[6.0]
  def change
    add_column :decks, :minimum_difficulty, :integer, default: 1
  end
end
