document.addEventListener("DOMContentLoaded", function () {
    const onCampusBtn = document.getElementById("on_campus");
    const offCampusBtn = document.getElementById("off_campus");
    const otherLocationBtn = document.getElementById("other_location");
    const onCampusFields = document.getElementById("on-campus-fields");
    const offCampusFields = document.getElementById("off-campus-fields");
    const otherLocationFields = document.getElementById("other-location-fields");
    const startTimeField = document.getElementById("starts_at");
    const endTimeField = document.getElementById("ends_at");

    // Initialize Bootstrap Tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Helper - Get local Machine Time in YYYY-MM-DDTHH:MM format
    function fmt(d) {
        const pad = (n) => String(n).padStart(2, "0");
        return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
    }

    // Helper - Adds at least 1 minute from start time to a date object for end time selection
    function addMinutes(date, minutes) {
        const d = new Date(date.getTime());
        d.setMinutes(d.getMinutes() + minutes);
        return d;
    }

    // Helper - Toggles display of on-campus and off-campus fields
    function toggleLocationFields() {
        if (onCampusBtn.checked) {
            onCampusFields.style.display = "block";
            offCampusFields.style.display = "none";
            otherLocationFields.style.display = "none";
        } 
        else if (offCampusBtn.checked) {
            onCampusFields.style.display = "none";
            offCampusFields.style.display = "block";
            otherLocationFields.style.display = "none";
        }
        else if (otherLocationBtn.checked) {
            onCampusFields.style.display = "none";
            offCampusFields.style.display = "none";
            otherLocationFields.style.display = "block";
        } 
        else {
            onCampusFields.style.display = "none";
            offCampusFields.style.display = "none";
            otherLocationFields.style.display = "none";
        }
    }

    // Helper - Syncs end time minimum to be at least 1 minute after start time
    function syncEndMinToStart() {
        if (!startTimeField.value) return;
        const start = new Date(startTimeField.value);
        const minEnd = addMinutes(start, 1);
        endTimeField.min = fmt(minEnd);

        if (!endTimeField.value || new Date(endTimeField.value) < minEnd) {
            endTimeField.value = fmt(minEnd);
        }
    }

    // Helper - Validates that end time is at least 1 minute after start time
    function validateEndTime() {
        if (startTimeField.value && endTimeField.value) {
            const start = new Date(startTimeField.value);
            const end = new Date(endTimeField.value);
            const minEnd = addMinutes(start, 1);
            if (end < minEnd) {
                endTimeField.value = fmt(minEnd);
                alert("End time must be at least 1 minute after start time.");
            }
        }
    }

    // Initialize time fields
    const now = new Date();
    now.setSeconds(0, 0);
    startTimeField.min = fmt(now);
    startTimeField.value ||= fmt(now);
    syncEndMinToStart();

    // Event listeners
    onCampusBtn?.addEventListener("change", toggleLocationFields);
    offCampusBtn?.addEventListener("change", toggleLocationFields);
    otherLocationBtn?.addEventListener("change", toggleLocationFields);
    startTimeField?.addEventListener("change", () => {
        syncEndMinToStart();
        validateEndTime();
    });
    endTimeField?.addEventListener("change", validateEndTime);

    // Initial state
    toggleLocationFields();
});