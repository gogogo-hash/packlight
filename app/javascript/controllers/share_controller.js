import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { title: String, text: String }
  static targets = ["label"]

  async share() {
    if (navigator.share) {
      try {
        await navigator.share({ title: this.titleValue, text: this.textValue })
        return
      } catch (error) {
        if (error.name === "AbortError") return
      }
    }

    await this.copy()
  }

  async copy() {
    await navigator.clipboard.writeText(this.textValue)
    this.flashCopied()
  }

  flashCopied() {
    const label = this.hasLabelTarget ? this.labelTarget : this.element
    const original = label.textContent
    label.textContent = "Copied!"
    setTimeout(() => { label.textContent = original }, 2000)
  }
}
