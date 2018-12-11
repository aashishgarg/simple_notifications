class CreateSimpleNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table(:simple_notifications) do |t|
      t.references :receiver, polymorphic: true
      t.references :sender, polymorphic: true
      t.string :message
      t.boolean :is_delivered, default: false

      t.timestamps
    end

    add_index(:simple_notifications, [:receiver_id, :receiver_type])
    add_index(:simple_notifications, [:sender_id, :sender_type])
    add_index(:simple_notifications, :is_delivered)
  end
end
