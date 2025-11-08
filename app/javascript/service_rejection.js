document.addEventListener("DOMContentLoaded", () => {
  // Toggle reject form when "Reject" button clicked
  document.querySelectorAll(".toggle-reject-form").forEach(button => {
    button.addEventListener("click", () => {
      const id = button.dataset.serviceId;
      const form = document.getElementById(`reject-form-${id}`);
      form.style.display = form.style.display === "none" ? "block" : "none";
    });
  });

  // Cancel button hides the form
  document.querySelectorAll(".cancel-reject-form").forEach(button => {
    button.addEventListener("click", () => {
      const id = button.dataset.serviceId;
      const form = document.getElementById(`reject-form-${id}`);
      form.style.display = "none";
    });
  });
});