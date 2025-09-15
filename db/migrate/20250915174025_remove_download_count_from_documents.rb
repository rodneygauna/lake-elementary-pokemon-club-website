class RemoveDownloadCountFromDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :documents, :download_count, :integer
  end
end
