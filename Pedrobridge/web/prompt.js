;(function (window) {
  class BridgePromptUI {
    constructor() {
      this.wrapper = document.getElementById("prompt-wrapper")
      this.input = document.getElementById("prompt-input")
      this.inputLabel = document.getElementById("prompt-input-label") || document.querySelector(".input-label")
    }

    setStrings(strings = {}) {
      if (this.inputLabel) this.inputLabel.textContent = strings.inputLabel || ""

      if (this.input) {
        if (strings.placeholder) {
          this.input.placeholder = strings.placeholder
        } else {
          this.input.removeAttribute("placeholder")
        }
      }
    }

    setActive(isActive) {
      if (this.wrapper) this.wrapper.classList.toggle("hidden", !isActive)
    }

    open(data = {}, strings) {
      this.setStrings({ ...strings, placeholder: data.placeholder })
      this.setActive(true)
      if (this.input) {
        this.input.value = ""
        setTimeout(() => {
          this.input.focus()
        }, 0)
      }
    }

    close() {
      this.setActive(false)
      if (this.input) this.input.value = ""
    }
  }

  window.BridgePromptUI = BridgePromptUI
})(window)
