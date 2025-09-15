class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title, null: false
      t.text :description
      t.string :document_type, null: false
      t.text :url
      t.integer :download_count, default: 0, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :documents, :document_type
    add_index :documents, :created_at
    add_index :documents, [ :document_type, :created_at ]
  end
end
