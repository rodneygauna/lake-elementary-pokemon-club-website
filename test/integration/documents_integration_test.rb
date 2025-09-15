require "test_helper"

class DocumentsIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
  end

  test "complete admin workflow: create, view, edit, delete document" do
    # Sign in as admin
    sign_in(@admin_user)

    # Navigate to documents index
    get admin_documents_path
    assert_response :success
    assert_select "h1", text: "Document Management"

    # Click "Create New Document"
    get new_admin_document_path
    assert_response :success
    assert_select "h1", text: "Create New Document"

    # Create a new link document
    post admin_documents_path, params: {
      document: {
        title: "Integration Test Link",
        description: "Test link created during integration test",
        document_type: "link",
        url: "https://integration-test.com"
      }
    }

    document = Document.last
    assert_redirected_to admin_document_path(document)
    follow_redirect!

    # Verify document details page
    assert_response :success
    assert_select "h1", text: "Integration Test Link"
    assert_includes response.body, "Test link created during integration test"
    assert_includes response.body, "https://integration-test.com"

    # Edit the document
    get edit_admin_document_path(document)
    assert_response :success
    assert_select "input[value='Integration Test Link']"

    patch admin_document_path(document), params: {
      document: {
        title: "Updated Integration Test Link",
        description: "Updated description for integration test"
      }
    }

    assert_redirected_to admin_document_path(document)
    follow_redirect!

    # Verify the update
    assert_select "h1", text: "Updated Integration Test Link"
    assert_includes response.body, "Updated description for integration test"

    # Delete the document
    assert_difference("Document.count", -1) do
      delete admin_document_path(document)
    end

    assert_redirected_to admin_documents_path
    follow_redirect!
    assert_equal "Document was successfully deleted.", flash[:notice]
  end

  test "complete public user workflow: browse resources and download files" do
    # Visit public resources page without authentication
    get public_resources_path
    assert_response :success
    assert_select "h1", text: "Club Resources"

    # Check that page contains resource content
    assert response.body.include?("External Links") || response.body.include?("Links")
    assert response.body.include?("File Downloads") || response.body.include?("Downloads")

    # Verify link documents are displayed
    link_doc = documents(:pokemon_guide_link)
    assert_select "td", text: link_doc.title
    assert_includes response.body, link_doc.url

    # Verify file documents are displayed
    file_doc = documents(:club_rules_pdf)
    assert_select "td", text: file_doc.title

    # Test expandable descriptions (if implemented)
    assert_includes response.body, link_doc.description
    assert_includes response.body, file_doc.description
  end

  test "admin can manage both link and file documents" do
    sign_in(@admin_user)

    # Create a link document
    post admin_documents_path, params: {
      document: {
        title: "Pokemon Official Site",
        description: "Official Pokemon website with news and games",
        document_type: "link",
        url: "https://www.pokemon.com"
      }
    }

    link_document = Document.last
    assert link_document.link?
    assert_equal "https://www.pokemon.com", link_document.url

    # Create a file document
    file = fixture_file_upload("test.pdf", "application/pdf")
    post admin_documents_path, params: {
      document: {
        title: "Club Handbook",
        description: "Complete handbook for club members",
        document_type: "file",
        file_attachment: file
      }
    }

    file_document = Document.last
    assert file_document.file?
    assert file_document.file_attachment.attached?
    assert_nil file_document.url

    # Verify both appear in admin index
    get admin_documents_path
    assert_response :success
    assert response.body.include?("Pokemon Official Site")
    assert response.body.include?("Club Handbook")

    # Verify filtering works
    get admin_documents_path, params: { document_type: "link" }
    assert_response :success
    assert response.body.include?("Pokemon Official Site")
    assert !response.body.include?("Club Handbook")

    get admin_documents_path, params: { document_type: "file" }
    assert_response :success
    assert response.body.include?("Club Handbook")
    assert_select "td", text: "Pokemon Official Site", count: 0
  end

  test "regular users cannot access admin interface" do
    sign_in(@regular_user)

    # Try to access admin documents
    get admin_documents_path
    assert_redirected_to root_path
    assert_equal "You must be an admin to access this page.", flash[:alert]

    # Try to create document
    post admin_documents_path, params: {
      document: { title: "Unauthorized", document_type: "link" }
    }
    assert_redirected_to root_path

    # Try to edit document
    document = documents(:pokemon_guide_link)
    get edit_admin_document_path(document)
    assert_redirected_to root_path

    # Try to delete document
    delete admin_document_path(document)
    assert_redirected_to root_path
  end

  test "public resources page handles empty state gracefully" do
    # Remove all documents to test empty state
    Document.destroy_all

    get public_resources_path
    assert_response :success
    assert_select "h1", "Club Resources"
    assert_includes response.body, "Resources Coming Soon"
  end

  test "document creation validates required fields" do
    sign_in(@admin_user)

    # Try to create document without required fields
    post admin_documents_path, params: {
      document: {
        title: "",
        description: "",
        document_type: "link",
        url: ""
      }
    }

    assert_response :unprocessable_entity
    assert_select "div.alert", text: /error/i

    # Should show validation errors
    assert response.body.include?("can't be blank") || response.body.include?("blank")
  end

  test "link documents require valid URLs" do
    sign_in(@admin_user)

    # Try to create link with invalid URL
    post admin_documents_path, params: {
      document: {
        title: "Invalid Link",
        description: "This should fail",
        document_type: "link",
        url: "not-a-valid-url"
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "must be a valid URL"
  end

  test "admin dashboard shows accurate statistics" do
    sign_in(@admin_user)

    # Get current counts
    total_docs = Document.count
    link_docs = Document.links.count

    get admin_documents_path
    assert_response :success

    # Verify statistics are displayed
    assert_includes response.body, "#{total_docs} Document"
    assert_includes response.body, "#{link_docs}"

    # Create a new document and verify stats update
    post admin_documents_path, params: {
      document: {
        title: "New Test Document",
        description: "For statistics test",
        document_type: "link",
        url: "https://test.com"
      }
    }

    get admin_documents_path
    assert_response :success
    assert_includes response.body, "#{total_docs + 1} Document"
    assert_includes response.body, "#{link_docs + 1}"
  end

  test "document show page displays all relevant information" do
    sign_in(@admin_user)
    document = documents(:pokemon_guide_link)

    get admin_document_path(document)
    assert_response :success

    # Should show document details
    assert_select "h1", text: document.title
    assert_includes response.body, document.description
    assert_includes response.body, document.url

    # Should show metadata
    assert_includes response.body, document.created_by.full_name
    assert_includes response.body, document.created_at.strftime("%B %d, %Y")

    # Should show action buttons
    assert_select "a[href='#{edit_admin_document_path(document)}']", text: /Edit/
    assert_select "button", text: /Delete/

    # Should show link to public resources page
    assert_select "a[href='#{public_resources_path}']", text: /View Public Resources Page/
  end

  private

  def sign_in(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
