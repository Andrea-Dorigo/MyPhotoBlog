import { Controller } from "stimulus";

export default class extends Controller {
  submit() {
    document.getElementById("comment_body").value = "";
    window.scrollBy(0, 200);
  }
}
