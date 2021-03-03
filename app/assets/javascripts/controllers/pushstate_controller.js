import { Controller } from "stimulus";


export default class extends Controller {
  push() {
    document.getElementById("hidden_word").setAttribute("value", this.element.innerHTML);
    history.pushState("data","title", this.element.href);
  }
}
