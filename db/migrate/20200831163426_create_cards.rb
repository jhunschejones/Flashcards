class CreateCards < ActiveRecord::Migration[6.0]
  def change
    create_table :cards do |t|
      t.text :english, null: false
      t.text :japanese, null: false

      t.timestamps
    end

    add_index :cards, [:english, :japanese], unique: true
  end
end
