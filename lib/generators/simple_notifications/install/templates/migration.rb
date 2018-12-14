class CreateSimpleNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table(:simple_notifications) do |t|
      t.references :sender, polymorphic: true
      t.references :entity, polymorphic: true
      t.string :message

      t.timestamps
    end

    create_table(:deliveries) do |t|
      t.references :simple_notification
      t.references :receiver, polymorphic: true
      t.boolean :is_delivered, default: false
      t.string :message

      t.timestamps
    end

    add_index(:simple_notifications, [:sender_id, :sender_type])
    add_index(:simple_notifications, [:entity_id, :entity_type])
    add_index(:deliveries, [:sender_id, :sender_type])
    add_index(:deliveries, :is_delivered)
  end
end
