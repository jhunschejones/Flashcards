class AddRandommizedToDeck < ActiveRecord::Migration[6.0]
  def change
    add_column :decks, :is_randomized, :boolean, default: false
  end
end
