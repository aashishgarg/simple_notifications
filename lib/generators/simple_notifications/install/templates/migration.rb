class CreateSimpleNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table(:simple_notifications) do |t|
      t.references :sender, polymorphic: true
      t.references :entity, polymorphic: true
      t.string :action
      t.string :message

      t.timestamps
    end

    create_table(:deliveries) do |t|
      t.references :simple_notification
      t.references :receiver, polymorphic: true
      t.boolean :is_delivered, default: false
      t.boolean :is_read, default: false

      t.timestamps
    end

    add_index(:simple_notifications, [:sender_id, :sender_type])
    add_index(:simple_notifications, [:entity_id, :entity_type])
    add_index(:deliveries, [:receiver_id, :receiver_type])
    add_index(:deliveries, :is_delivered)
    add_index(:deliveries, :is_read)
  end
end
