document.getElementById("check-all")?.addEventListener("change", (e) => {
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

  document.getElementById("top-bulk-edit")?.addEventListener("click", () => {
    pushSelectedToHiddenForm();
    document.getElementById("bulk-edit-form").submit();
  });