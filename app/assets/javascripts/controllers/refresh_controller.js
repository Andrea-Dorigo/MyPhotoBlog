import { Controller } from "stimulus";

export default class extends Controller {
  rotate() {
    document.getElementById("refresh_icon").classList.add("rotating");
  }
  connect() {
    document.getElementById("refresh_icon").classList.remove("rotating");
  }
}
