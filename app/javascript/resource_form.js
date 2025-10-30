document.addEventListener("DOMContentLoaded", function () {
  const fileOption = document.getElementById("file_option");
  const linkOption = document.getElementById("link_option");
  const fileFields = document.getElementById("file-fields");
  const linkFields = document.getElementById("link-fields");

  // Initialize Bootstrap Tooltips
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });

  // Function to toggle between file and link fields
  function toggleResourceFields() {
    if (fileOption.checked) {
      fileFields.style.display = "block";
      linkFields.style.display = "none";
    } else if (linkOption.checked) {
      fileFields.style.display = "none";
      linkFields.style.display = "block";
    } else {
      fileFields.style.display = "none";
      linkFields.style.display = "none";
    }
  }

  [fileOption, linkOption].forEach(el => el.addEventListener("change", toggleResourceFields));
  toggleResourceFields(); // initialize
});