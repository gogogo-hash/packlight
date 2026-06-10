import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "drawer", "icon" ]

  toggle() {
    this.drawerTarget.classList.toggle("hidden")

    const isHidden = this.drawerTarget.classList.contains("hidden")
    if (isHidden) {
      this.iconTarget.setAttribute("d", "M4 6h16M4 12h16M4 18h16") // Hamburger
    } else {
      this.iconTarget.setAttribute("d", "M6 18L18 6M6 6l12 12") // X Close
    }
  }
}