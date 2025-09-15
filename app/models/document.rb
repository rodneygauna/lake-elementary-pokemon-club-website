class Document < ApplicationRecord
  # ----- Enums -----
  enum :document_type, { link: "link", file: "file" }

  # ----- Validations -----
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :document_type, presence: true
  validates :url, presence: true, if: :link?
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, if: -> { link? && url.present? }
  validate :file_attachment_present, if: :file?
  validate :file_attachment_size, if: -> { file? && file_attachment.attached? }
  validate :file_attachment_type, if: -> { file? && file_attachment.attached? }

  # ----- Associations -----
  has_one_attached :file_attachment do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 300, 300 ]
    attachable.variant :preview, resize_to_limit: [ 600, 600 ]
  end
  belongs_to :created_by, class_name: "User", optional: false

  # ----- Normalizations -----
  normalizes :url, with: ->(url) { url.strip.downcase if url.present? }

  # ----- Callbacks -----
  before_save :clear_url_if_file_type

  # ----- Scopes -----
  # Ordering
  scope :ordered, -> { order(:title) }
  scope :recent_first, -> { order(created_at: :desc) }

  # Type-based
  scope :links, -> { where(document_type: "link") }
  scope :files, -> { where(document_type: "file") }

  # ----- Instance Methods -----
  def display_name
    title.present? ? title : "Untitled Document"
  end

  def file_size
    file_attachment.attached? ? file_attachment.byte_size : 0
  end

  def file_type
    return nil unless file_attachment.attached?
    file_attachment.content_type
  end

  def is_image?
    return false unless file_attachment.attached?
    file_attachment.content_type&.start_with?("image/")
  end

  def file_extension
    return nil unless file_attachment.attached?
    File.extname(file_attachment.filename.to_s).downcase.remove(".")
  end

  private

  def file_attachment_present
    unless file_attachment.attached?
      errors.add(:file_attachment, "must be attached for file type documents")
    end
  end

  def file_attachment_size
    if file_attachment.byte_size > 10.megabytes
      errors.add(:file_attachment, "must be less than 10MB")
    end
  end

  def file_attachment_type
    allowed_types = %w[
      image/jpeg image/jpg image/png image/gif image/webp
      application/pdf
      application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.ms-powerpoint application/vnd.openxmlformats-officedocument.presentationml.presentation
      text/plain text/csv
    ]

    unless allowed_types.include?(file_attachment.content_type)
      errors.add(:file_attachment, "must be a valid file type (PDF, Word, Excel, PowerPoint, images, or text files)")
    end
  end

  def clear_url_if_file_type
    self.url = nil if file?
  end
end
