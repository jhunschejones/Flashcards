class AddMaximumDifficultyToDeck < ActiveRecord::Migration[6.0]
  def change
    add_column :decks, :maximum_difficulty, :integer, default: 5
  end
end
