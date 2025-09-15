class Admin::DocumentsController < ApplicationController
  before_action :require_admin_level
  before_action :require_admin, only: [ :destroy ]
  before_action :set_document, only: [ :show, :edit, :update, :destroy ]

  def index
    @documents = Document.recent_first

    # Apply document type filter if present
    if params[:document_type].present?
      @documents = @documents.where(document_type: params[:document_type])
    end
  end

  def show
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params)
    @document.created_by = current_user

    if @document.save
      redirect_to admin_document_path(@document), notice: "Document was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @document.update(document_params)
      redirect_to admin_document_path(@document), notice: "Document was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy!
    redirect_to admin_documents_path, notice: "Document was successfully deleted."
  end

  private

  def set_document
    @document = Document.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_documents_path, alert: "Document not found."
  end

  def document_params
    params.require(:document).permit(:title, :description, :document_type, :url, :file_attachment)
  end
end
