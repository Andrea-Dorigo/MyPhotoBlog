import { Controller } from "stimulus";

var clickable = true;

export default class extends Controller {
  rotate() {
    this.element.classList.add("rotating");
    clickable ? clickable = false : event.preventDefault() ;
  }
  connect() {
    document.getElementById("refresh_icon").classList.remove("rotating");
    clickable = true;
  }
}
