import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="events-calendar"
export default class extends Controller {
  static targets = ["calendar"];
  static values = {
    events: Array,
    currentUser: Object,
  };

  connect() {
    console.log("Calendar controller connected");
    console.log("Events data:", this.eventsValue);

    // Wait for FullCalendar to be available
    this.waitForFullCalendar();
  }

  disconnect() {
    console.log("Calendar controller disconnecting");
    if (this.calendar) {
      this.calendar.destroy();
      this.calendar = null;
    }
  }

  waitForFullCalendar(attempts = 0) {
    if (typeof FullCalendar !== "undefined") {
      this.initializeCalendar();
    } else if (attempts < 10) {
      // Retry up to 10 times with increasing delay
      setTimeout(() => {
        this.waitForFullCalendar(attempts + 1);
      }, 50 * (attempts + 1));
    } else {
      console.error("FullCalendar failed to load after multiple attempts");
      this.calendarTarget.innerHTML =
        '<div class="alert alert-warning">Calendar library failed to load. Please refresh the page.</div>';
    }
  }

  initializeCalendar() {
    console.log("Initializing FullCalendar...");

    // Make sure we have a clean target
    this.calendarTarget.innerHTML = "";

    this.calendar = new FullCalendar.Calendar(this.calendarTarget, {
      themeSystem: "bootstrap5",

      // Calendar settings
      initialView: "dayGridMonth",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth",
      },

      // Pokemon theme colors
      eventColor: "#0084FF",

      // Mobile responsive
      height: "auto",
      aspectRatio: 1.35,

      // Events data
      events: this.processEvents(),

      // Event styling
      eventDidMount: (info) => {
        const event = info.event;
        const extendedProps = event.extendedProps;

        // Add status classes
        if (extendedProps.status === "canceled") {
          info.el.classList.add("fc-event-canceled");
          info.el.style.backgroundColor = "#dc3545";
          info.el.style.borderColor = "#dc3545";
        } else if (extendedProps.status === "draft") {
          info.el.classList.add("fc-event-draft");
          info.el.style.backgroundColor = "#6c757d";
          info.el.style.borderColor = "#6c757d";
        }

        // Add special event styling
        if (extendedProps.special) {
          info.el.classList.add("fc-event-special");
          // Keep the standard event color, just add bold font weight
          info.el.style.fontWeight = "bold";
        }

        // Add tooltip
        info.el.title = extendedProps.description || event.title;

        // Make events clickable
        info.el.addEventListener("click", () => {
          window.location.href = `/events/${extendedProps.id}`;
        });
        info.el.style.cursor = "pointer";
      },

      // Day cell styling
      dayCellDidMount: (info) => {
        // Add subtle Pokemon theme to today
        if (info.isToday) {
          info.el.style.backgroundColor = "rgba(0, 132, 255, 0.1)";
        }
      },
    });

    console.log(
      "About to render calendar with",
      this.processEvents().length,
      "events"
    );
    this.calendar.render();
    console.log("Calendar render complete");
  }

  processEvents() {
    return this.eventsValue
      .map((event) => {
        // Only show events user is allowed to see
        if (event.status === "draft" && !this.currentUserValue?.admin) {
          return null;
        }

        return {
          id: event.id,
          title: this.formatEventTitle(event),
          start: event.starts_at,
          end: event.ends_at,
          allDay: false,
          extendedProps: {
            id: event.id,
            status: event.status,
            special: event.special,
            description: event.description,
            venue: event.venue,
          },
        };
      })
      .filter(Boolean); // Remove null entries
  }

  formatEventTitle(event) {
    let title = event.title;

    // Add status indicators
    if (event.status === "canceled") {
      title = `[CANCELLED] ${title}`;
    } else if (event.status === "draft") {
      title = `[DRAFT] ${title}`;
    }

    // Add special event indicator
    if (event.special) {
      title = `⭐ ${title}`;
    }

    return title;
  }
}
