document.addEventListener("turbo:load", () => {
  const checkAll = document.getElementById("check-all");
  const topBulkEdit = document.getElementById("top-bulk-edit");

  if (!checkAll || !topBulkEdit) return; // skip if elements are not on this page

  console.log("directory.js loaded", checkAll, topBulkEdit);

  checkAll.addEventListener("change", (e) => {
    document.querySelectorAll(".user-checkbox").forEach(cb => cb.checked = e.target.checked);
  });

  function pushSelectedToHiddenForm() {
    const holder = document.getElementById("bulk-edit-selected");
    holder.innerHTML = "";
    document.querySelectorAll(".user-checkbox:checked").forEach(cb => {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "user_ids[]";
      input.value = cb.value;
      holder.appendChild(input);
    });
  }

  topBulkEdit.addEventListener("click", (e) => {
    e.preventDefault(); // prevent form double submit
    pushSelectedToHiddenForm();
    document.getElementById("bulk-edit-form").submit();
  });
});
