import { Controller } from "stimulus";


export default class extends Controller {
  connect() {
    document.getElementById("hidden_word").setAttribute("value", this.element.innerHTML);
  }
}
