// Entry point for the build script in your package.json
import Rails from "@rails/ujs"
Rails.start()

import "best_in_place"
document.addEventListener("turbo:load", () => {
  /* activate best_in_place */
  $(".best_in_place").best_in_place();
});