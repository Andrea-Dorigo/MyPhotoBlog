import { Controller } from "stimulus";

export default class extends Controller {
  test() {
    history.pushState("data","title", this.element.href);
  }
}
