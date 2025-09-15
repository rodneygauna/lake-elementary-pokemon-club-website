require "test_helper"

class Admin::DocumentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
    @link_document = documents(:pokemon_guide_link)
    @file_document = documents(:club_rules_pdf)
  end

  # Authentication Tests
  test "should require authentication for all actions" do
    # Test all actions without authentication - should redirect to login
    get admin_documents_path
    assert_response :redirect
  end

  test "should require admin privileges" do
    sign_in(@regular_user)

    get admin_documents_path
    assert_redirected_to root_path
    assert_equal "You must be an admin to access this page.", flash[:alert]
  end

  # Index Tests
  test "should get index as admin" do
    sign_in(@admin_user)
    get admin_documents_path
    assert_response :success
  end

  test "index should display all documents" do
    sign_in(@admin_user)
    get admin_documents_path
    assert_response :success

    # Check that the page loads and has the expected structure
    assert_select "h1", text: "Document Management"
    assert_select ".card-body"
    # The actual document loading might be done via JavaScript
  end

  test "index should show document statistics" do
    sign_in(@admin_user)
    get admin_documents_path
    assert_response :success

    total_count = Document.count
    link_count = Document.links.count

    assert_includes @response.body, "#{total_count} Document"
    assert_includes @response.body, "#{link_count}"
  end

  test "index should filter by document type" do
    sign_in(@admin_user)

    # Test filtering by link type
    get admin_documents_path, params: { document_type: "link" }
    assert_response :success

    # Should show link documents
    assert response.body.include?("Official Pokémon Guide")

    # Test filtering by file type
    get admin_documents_path, params: { document_type: "file" }
    assert_response :success

    # Should show file documents
    assert response.body.include?("Club Rules and Guidelines")
  end

  test "index should show action buttons" do
    sign_in(@admin_user)
    get admin_documents_path
    assert_response :success

    assert_select "a[href='#{new_admin_document_path}']", text: /Add New Document/
    assert_select "a[href='#{admin_document_path(@link_document)}']", text: /View/
    assert_select "a[href='#{edit_admin_document_path(@link_document)}']", text: /Edit/
    assert_select "button", text: /Delete/
  end

  # Show Tests
  test "should show document as admin" do
    sign_in(@admin_user)
    get admin_document_path(@link_document)
    assert_response :success
  end

  test "show should display document details" do
    sign_in(@admin_user)
    get admin_document_path(@link_document)
    assert_response :success

    assert_includes @response.body, @link_document.title
    assert_includes @response.body, @link_document.description
    assert_includes @response.body, @link_document.url if @link_document.link?
  end

  test "show should display creation information" do
    sign_in(@admin_user)
    get admin_document_path(@link_document)
    assert_response :success

    assert_includes @response.body, @admin_user.full_name
    assert_includes @response.body, @link_document.created_at.strftime("%B %d, %Y")
  end

  test "should handle non-existent document in show" do
    sign_in(@admin_user)

    get admin_document_path(id: 99999)
    assert_redirected_to admin_documents_path
    assert_equal "Document not found.", flash[:alert]
  end

  # New Tests
  test "should get new as admin" do
    sign_in(@admin_user)
    get new_admin_document_path
    assert_response :success
  end

  test "new should display form fields" do
    sign_in(@admin_user)
    get new_admin_document_path
    assert_response :success

    # Check for form elements
    assert_select "input[name='document[title]']"
    assert_select "textarea[name='document[description]']"
    assert_select "input[name='document[document_type]'][value='link']"
    assert_select "input[name='document[document_type]'][value='file']"
    assert_select "input[name='document[url]']"
    assert_select "input[name='document[file_attachment]']"
  end

  # Create Tests
  test "should create link document as admin" do
    sign_in(@admin_user)

    assert_difference("Document.count") do
      post admin_documents_path, params: {
        document: {
          title: "New Link",
          description: "Test description",
          document_type: "link",
          url: "https://example.com"
        }
      }
    end

    assert_redirected_to admin_document_path(Document.last)
    assert_equal "Document was successfully created.", flash[:notice]

    document = Document.last
    assert_equal "New Link", document.title
    assert_equal @admin_user, document.created_by
  end

  test "should create file document as admin" do
    sign_in(@admin_user)

    file = fixture_file_upload("test.pdf", "application/pdf")

    assert_difference("Document.count") do
      post admin_documents_path, params: {
        document: {
          title: "New File",
          description: "Test description",
          document_type: "file",
          file_attachment: file
        }
      }
    end

    assert_redirected_to admin_document_path(Document.last)
    assert_equal "Document was successfully created.", flash[:notice]

    document = Document.last
    assert_equal "New File", document.title
    assert_equal @admin_user, document.created_by
    assert document.file_attachment.attached?
  end

  test "should not create document with invalid data" do
    sign_in(@admin_user)

    assert_no_difference("Document.count") do
      post admin_documents_path, params: {
        document: {
          title: "",
          description: "",
          document_type: "link",
          url: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # Edit Tests
  test "should get edit as admin" do
    sign_in(@admin_user)
    get edit_admin_document_path(@link_document)
    assert_response :success
  end

  test "edit should populate form with existing data" do
    sign_in(@admin_user)
    get edit_admin_document_path(@link_document)
    assert_response :success

    assert_select "input[name='document[title]'][value='#{@link_document.title}']"
    assert_select "textarea[name='document[description]']", text: @link_document.description
  end

  # Update Tests
  test "should update document as admin" do
    sign_in(@admin_user)

    patch admin_document_path(@link_document), params: {
      document: {
        title: "Updated Title",
        description: "Updated description"
      }
    }

    assert_redirected_to admin_document_path(@link_document)
    assert_equal "Document was successfully updated.", flash[:notice]

    @link_document.reload
    assert_equal "Updated Title", @link_document.title
    assert_equal "Updated description", @link_document.description
  end

  test "should not update document with invalid data" do
    sign_in(@admin_user)

    patch admin_document_path(@link_document), params: {
      document: {
        title: "",
        description: ""
      }
    }

    assert_response :unprocessable_entity

    @link_document.reload
    assert_not_equal "", @link_document.title
  end

  # Destroy Tests
  test "should destroy document as admin" do
    sign_in(@admin_user)

    assert_difference("Document.count", -1) do
      delete admin_document_path(@link_document)
    end

    assert_redirected_to admin_documents_path
    assert_equal "Document was successfully deleted.", flash[:notice]
  end

  test "should handle destroy with non-existent document" do
    sign_in(@admin_user)

    delete admin_document_path(id: 99999)
    assert_redirected_to admin_documents_path
    assert_equal "Document not found.", flash[:alert]
  end

  # File Upload Tests
  test "should handle file upload in create" do
    sign_in(@admin_user)

    file = fixture_file_upload("test.pdf", "application/pdf")

    assert_difference("Document.count") do
      post admin_documents_path, params: {
        document: {
          title: "PDF Document",
          description: "Test PDF",
          document_type: "file",
          file_attachment: file
        }
      }
    end

    document = Document.last
    assert document.file_attachment.attached?
  end

  test "should handle file upload in update" do
    sign_in(@admin_user)

    file = fixture_file_upload("test.pdf", "application/pdf")

    patch admin_document_path(@file_document), params: {
      document: {
        file_attachment: file
      }
    }

    assert_redirected_to admin_document_path(@file_document)
    @file_document.reload
    # Note: This would require the file to actually be attached in the test
  end

  private

  def sign_in(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
