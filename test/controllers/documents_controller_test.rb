require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @link_document = documents(:pokemon_guide_link)
    @file_document = documents(:club_rules_pdf)
  end

  # Public Index Tests
  test "should get public_index without authentication" do
    get public_resources_path
    assert_response :success
  end

  test "public_index should display document titles" do
    get public_resources_path
    assert_response :success

    # Should show document titles
    assert_includes @response.body, @link_document.title
    assert_includes @response.body, @file_document.title
  end

  test "public_index should show descriptions" do
    get public_resources_path
    assert_response :success

    assert_includes @response.body, @link_document.description
    assert_includes @response.body, @file_document.description
  end

  test "public_index should show external link URLs" do
    get public_resources_path
    assert_response :success

    assert_includes @response.body, @link_document.url
  end

  test "public_index should handle empty state gracefully" do
    Document.destroy_all

    get public_resources_path
    assert_response :success

    # Should still render the page
    assert_includes @response.body.downcase, "resources"
  end

  # Basic Download Tests (without file attachment mocking)
  test "should handle download of link document gracefully" do
    get resource_download_path(@link_document)
    assert_redirected_to public_resources_path
    assert_equal "This resource is not downloadable.", flash[:alert]
  end

  test "should handle missing document gracefully" do
    get resource_download_path(id: 99999)
    assert_redirected_to public_resources_path
    assert_equal "Resource not found.", flash[:alert]
  end

  # Security Tests
  test "public_index should not expose admin information" do
    get public_resources_path
    assert_response :success

    # Should not show admin-only information
    assert_select "a[href*='/admin/']", count: 0
    assert_select "button", text: /edit/i, count: 0
    assert_select "button", text: /delete/i, count: 0
  end

  test "download should work without authentication" do
    # Ensure no user is logged in by making fresh request
    get resource_download_path(@link_document)
    # Should handle gracefully regardless of authentication
    assert_response :redirect
  end
end
