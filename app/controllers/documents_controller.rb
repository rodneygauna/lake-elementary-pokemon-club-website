class DocumentsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_document, only: [ :download ]

  def public_index
    @documents = Document.ordered
    @link_documents = Document.links.ordered
    @file_documents = Document.files.ordered
  end

  def download
    # Only allow downloads for file type documents
    unless @document.file?
      redirect_to public_resources_path, alert: "This resource is not downloadable."
      return
    end

    unless @document.file_attachment.attached?
      redirect_to public_resources_path, alert: "File not found."
      return
    end

    # Redirect to the actual file
    redirect_to url_for(@document.file_attachment), allow_other_host: false
  end

  private

  def set_document
    @document = Document.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to public_resources_path, alert: "Resource not found."
  end
end
