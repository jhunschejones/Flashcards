class AddDifficultyToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :difficulty, :integer, default: 5
  end
end
