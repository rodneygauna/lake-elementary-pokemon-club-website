import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["presentCount", "absentCount"];

  connect() {
    // Initialize event listeners for attendance toggle buttons
    this.initializeAttendanceToggles();
  }

  initializeAttendanceToggles() {
    const toggleButtons = document.querySelectorAll(".attendance-toggle");

    toggleButtons.forEach((button) => {
      button.addEventListener("click", (event) => {
        this.toggleAttendance(event.currentTarget);
      });
    });
  }

  async toggleAttendance(button) {
    const eventId = button.dataset.eventId;
    const studentId = button.dataset.studentId;
    const studentName = button.dataset.studentName;
    const isCurrentlyPresent = button.dataset.present === "true";

    // Disable button during request
    button.disabled = true;
    button.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Updating...';

    try {
      const response = await fetch(
        `/events/${eventId}/attendances/toggle/${studentId}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('[name="csrf-token"]')
              .content,
          },
        }
      );

      const data = await response.json();

      if (data.success) {
        // Update button state
        this.updateButtonState(
          button,
          data.present,
          studentName,
          data.marked_at
        );

        // Update summary counts
        this.updateSummaryCounts();

        // Show success feedback
        this.showToast(
          `${studentName} marked as ${data.present ? "present" : "absent"}`,
          "success"
        );
      } else {
        // Show error message
        this.showToast(`Error: ${data.error}`, "error");

        // Reset button to previous state
        this.updateButtonState(button, isCurrentlyPresent, studentName);
      }
    } catch (error) {
      console.error("Attendance toggle error:", error);
      this.showToast("Failed to update attendance. Please try again.", "error");

      // Reset button to previous state
      this.updateButtonState(button, isCurrentlyPresent, studentName);
    } finally {
      // Re-enable button
      button.disabled = false;
    }
  }

  updateButtonState(button, isPresent, studentName, markedAt = null) {
    // Update data attribute
    button.dataset.present = isPresent.toString();

    // Update button classes
    button.className = `btn w-100 attendance-toggle ${
      isPresent ? "btn-success" : "btn-outline-secondary"
    }`;

    // Update button content
    const iconClass = isPresent ? "fas fa-check-circle" : "far fa-circle";
    const statusText = isPresent ? "Present" : "";

    let buttonHTML = `<i class="${iconClass} me-2"></i>${studentName}`;

    if (isPresent && statusText) {
      buttonHTML += `<small class="d-block text-white-50 mt-1">
        <i class="fas fa-clock me-1"></i>${statusText}
      </small>`;
    }

    button.innerHTML = buttonHTML;
  }

  updateSummaryCounts() {
    const presentButtons = document.querySelectorAll(
      '.attendance-toggle[data-present="true"]'
    );
    const totalButtons = document.querySelectorAll(".attendance-toggle");

    const presentCount = presentButtons.length;
    const totalCount = totalButtons.length;
    const absentCount = totalCount - presentCount;

    // Update count displays
    const presentCountEl = document.getElementById("present-count");
    const absentCountEl = document.getElementById("absent-count");

    if (presentCountEl) presentCountEl.textContent = presentCount;
    if (absentCountEl) absentCountEl.textContent = absentCount;
  }

  showToast(message, type = "info") {
    // Create a simple toast notification
    const toast = document.createElement("div");
    toast.className = `alert alert-${
      type === "success" ? "success" : "danger"
    } alert-dismissible fade show position-fixed`;
    toast.style.cssText =
      "top: 20px; right: 20px; z-index: 1060; min-width: 300px;";

    toast.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;

    document.body.appendChild(toast);

    // Auto-remove after 3 seconds
    setTimeout(() => {
      if (toast.parentNode) {
        toast.remove();
      }
    }, 3000);
  }
}
