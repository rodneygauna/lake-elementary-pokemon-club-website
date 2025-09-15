require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user)
    @valid_link_attrs = {
      title: "Test Link",
      description: "Test description",
      document_type: "link",
      url: "https://example.com",
      created_by: @admin_user
    }
    @valid_file_attrs = {
      title: "Test File",
      description: "Test description",
      document_type: "file",
      created_by: @admin_user
    }
  end

  # Validation Tests
  test "should be valid with valid attributes for link" do
    document = Document.new(@valid_link_attrs)
    assert document.valid?
  end

  test "should be invalid with valid attributes for file without attachment" do
    document = Document.new(@valid_file_attrs)
    assert_not document.valid?
    assert_includes document.errors[:file_attachment], "must be attached for file type documents"
  end

  test "should require title" do
    document = Document.new(@valid_link_attrs.except(:title))
    assert_not document.valid?
    assert_includes document.errors[:title], "can't be blank"
  end

  test "description is optional" do
    document = Document.new(@valid_link_attrs.except(:description))
    assert document.valid?
  end

  test "should require document_type" do
    document = Document.new(@valid_link_attrs.except(:document_type))
    assert_not document.valid?
    assert_includes document.errors[:document_type], "can't be blank"
  end

  test "should require created_by" do
    document = Document.new(@valid_link_attrs.except(:created_by))
    assert_not document.valid?
    assert_includes document.errors[:created_by], "must exist"
  end

  test "should require URL for link documents" do
    document = Document.new(@valid_link_attrs.merge(url: ""))
    assert_not document.valid?
    assert_includes document.errors[:url], "can't be blank"
  end

  test "should validate URL format for link documents" do
    document = Document.new(@valid_link_attrs.merge(url: "not-a-url"))
    assert_not document.valid?
    assert_includes document.errors[:url], "must be a valid URL"
  end

  test "should accept http URLs" do
    document = Document.new(@valid_link_attrs.merge(url: "http://example.com"))
    assert document.valid?
  end

  test "should accept https URLs" do
    document = Document.new(@valid_link_attrs.merge(url: "https://example.com"))
    assert document.valid?
  end

  test "file documents do not require URL" do
    document = Document.new(@valid_file_attrs)
    # Still invalid because of missing file attachment, but not because of URL
    document.valid?
    assert_not_includes document.errors[:url], "can't be blank"
  end

  # Enum Tests
  test "should have correct document_type enum values" do
    assert_equal [ "link", "file" ], Document.document_types.keys
  end

  test "should respond to document_type predicates" do
    link_doc = Document.new(@valid_link_attrs)
    file_doc = Document.new(@valid_file_attrs)

    assert link_doc.link?
    assert_not link_doc.file?

    assert file_doc.file?
    assert_not file_doc.link?
  end

  # Scope Tests
  test "links scope should return only link documents" do
    link_doc = documents(:pokemon_guide_link)
    file_doc = documents(:club_rules_pdf)

    links = Document.links
    assert_includes links, link_doc
    assert_not_includes links, file_doc
  end

  test "files scope should return only file documents" do
    link_doc = documents(:pokemon_guide_link)
    file_doc = documents(:club_rules_pdf)

    files = Document.files
    assert_includes files, file_doc
    assert_not_includes files, link_doc
  end

  test "ordered scope should order by title" do
    # The ordered scope orders by title, not created_at
    docs = Document.ordered
    titles = docs.pluck(:title)
    assert_equal titles.sort, titles
  end

  test "recent_first scope should order by created_at desc" do
    # Just test that the scope applies the correct ordering
    recent_docs = Document.recent_first.to_a

    # Check that each document has a created_at timestamp that is >= the next one
    recent_docs.each_cons(2) do |current, next_doc|
      assert current.created_at >= next_doc.created_at,
             "Documents should be ordered by created_at descending"
    end
  end

  # Method Tests
  test "display_name should return title" do
    document = Document.new(@valid_link_attrs)
    assert_equal "Test Link", document.display_name
  end

  test "display_name should return default for blank title" do
    document = Document.new(@valid_link_attrs.merge(title: ""))
    assert_equal "Untitled Document", document.display_name
  end

  test "file_size should return 0 when no file attached" do
    document = Document.new(@valid_file_attrs)
    assert_equal 0, document.file_size
  end

  test "file_extension should return nil when no file attached" do
    document = Document.new(@valid_file_attrs)
    assert_nil document.file_extension
  end

  test "is_image? should return false when no file attached" do
    document = Document.new(@valid_file_attrs)
    assert_not document.is_image?
  end

  # Association Tests
  test "should belong to created_by user" do
    document = documents(:pokemon_guide_link)
    assert_equal users(:admin_user), document.created_by
  end

  test "should have one attached file_attachment" do
    document = Document.new(@valid_file_attrs)
    assert_respond_to document, :file_attachment
  end

  # Callback Tests
  test "should clear URL for file documents" do
    document = Document.new(@valid_file_attrs.merge(url: "https://example.com"))
    document.save(validate: false) # Skip validation to test callback
    assert_nil document.url
  end

  # Normalization Tests
  test "should normalize URL by stripping whitespace and downcasing" do
    document = Document.new(@valid_link_attrs.merge(url: "  HTTPS://EXAMPLE.COM  "))
    document.valid?
    assert_equal "https://example.com", document.url
  end

  # File validation tests would require actual file uploads,
  # which are more appropriate for integration tests
end
