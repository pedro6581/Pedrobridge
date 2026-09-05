;(function (window) {
  class BridgeRequestUI {
    constructor() {
      this.wrapper = document.getElementById("request-wrapper")
      this.modal = document.querySelector(".modal")
      this.timerValue = document.getElementById("modal-timer-value")
      this.acceptKey = document.getElementById("request-accept-key")
      this.acceptTitle = document.getElementById("request-accept-title")
      this.declineKey = document.getElementById("request-decline-key")
      this.declineTitle = document.getElementById("request-decline-title")

      this.requestTimerInterval = null
      this.requestExpiresAt = null
      this.requestTimerTotalMs = 0
    }

    setStrings(strings = {}) {
      if (this.acceptKey) this.acceptKey.textContent = strings.acceptKey || "Y"
      if (this.declineKey) this.declineKey.textContent = strings.declineKey || "N"

      if (this.acceptTitle) this.acceptTitle.textContent = strings.acceptTitle || ""
      if (this.declineTitle) this.declineTitle.textContent = strings.declineTitle || ""
    }

    setProgress(progress = 1) {
      const safeProgress = Math.max(0, Math.min(1, progress))
      if (this.modal) this.modal.style.setProperty("--request-progress", safeProgress)
    }

    setActive(isActive) {
      if (this.wrapper) this.wrapper.classList.toggle("hidden", !isActive)
      if (this.modal) this.modal.classList.toggle("has-request-progress", isActive)
    }

    stopTimer() {
      if (this.requestTimerInterval) {
        clearInterval(this.requestTimerInterval)
        this.requestTimerInterval = null
      }
      this.requestExpiresAt = null
      this.requestTimerTotalMs = 0
      if (this.timerValue) this.timerValue.textContent = "--"
      this.setProgress(1)
      if (this.modal) this.modal.classList.remove("has-request-progress")
    }

    updateTimer() {
      if (!this.requestExpiresAt) return

      const remainingMs = Math.max(0, this.requestExpiresAt - Date.now())
      const remainingSeconds = Math.max(0, Math.ceil(remainingMs / 1000))

      if (this.timerValue) this.timerValue.textContent = remainingSeconds
      if (this.requestTimerTotalMs > 0) {
        const progress = Math.max(0, Math.min(1, remainingMs / this.requestTimerTotalMs))
        this.setProgress(progress)
      }

      if (remainingMs <= 0) {
        this.stopTimer()
      }
    }

    startTimer(timeoutMs) {
      this.stopTimer()
      if (!timeoutMs || timeoutMs <= 0) return

      this.requestTimerTotalMs = timeoutMs
      this.requestExpiresAt = Date.now() + timeoutMs
      this.updateTimer()
      this.requestTimerInterval = setInterval(() => this.updateTimer(), 250)
    }

    open(data = {}, strings) {
      this.setStrings(strings)
      this.setActive(true)
      this.setProgress(1)
      this.startTimer(data.timeoutMs)
    }

    close() {
      this.stopTimer()
      this.setActive(false)
    }
  }

  window.BridgeRequestUI = BridgeRequestUI
})(window)
