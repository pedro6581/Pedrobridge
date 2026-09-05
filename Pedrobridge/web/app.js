const overlay = document.getElementById("overlay")
const modal = document.querySelector(".modal")
const modalIcon = document.getElementById("modal-icon")
const modalTitleText = document.getElementById("modal-title-text")
const modalTimer = document.getElementById("modal-timer")
const modalTimerValue = document.getElementById("modal-timer-value")
const promptInput = document.getElementById("prompt-input")
const promptConfirmButton = document.getElementById("prompt-confirm")
const promptCancelButton = document.getElementById("prompt-cancel")

const promptUI = new window.BridgePromptUI()
const requestUI = new window.BridgeRequestUI()

const defaultStrings = {
    promptTitle: "",
    requestTitle: "Pedido",
    inputLabel: "Preencha o campo abaixo",
    acceptTitle: "Aceitar",
    declineTitle: "Negar",
    acceptKey: "Y",
    declineKey: "N"
}

let activeStrings = { ...defaultStrings }
let currentMode = null
let currentRequestId = null

function resolveTitle(message) {
    if (message && message.trim() !== "") return message
    return currentMode === "request" ? activeStrings.requestTitle : activeStrings.promptTitle
}

function applyStrings(strings) {
    activeStrings = { ...defaultStrings, ...(strings || {}) }
    promptUI.setStrings(activeStrings)
    requestUI.setStrings(activeStrings)
}

function setMode(mode) {
    currentMode = mode
    overlay.classList.toggle("prompt-mode", mode === "prompt")
    overlay.classList.toggle("request-mode", mode === "request")
    modal.classList.toggle("is-prompt", mode === "prompt")
    modal.classList.toggle("is-request", mode === "request")

    promptUI.setActive(mode === "prompt")
    requestUI.setActive(mode === "request")
    if (modalTimer) modalTimer.classList.toggle("hidden", mode !== "request")
    if (modalIcon) modalIcon.classList.toggle("hidden", mode !== "request")
}

function openModal(data) {
    currentRequestId = data.requestId
    applyStrings(data.strings)
    setMode(data.mode)
    const modalTitleContent = resolveTitle(data.message || "")
    if (modalTitleText) modalTitleText.textContent = modalTitleContent

    if (data.mode === "prompt") {
        requestUI.close()
        promptUI.open(data, activeStrings)
    }

    if (data.mode === "request") {
        promptUI.close()
        requestUI.open(data, activeStrings)
    }

    overlay.classList.remove("hidden")
}

function closeModal() {
    overlay.classList.add("hidden")
    currentMode = null
    currentRequestId = null
    promptUI.close()
    requestUI.close()
    if (modalTitleText) modalTitleText.textContent = ""
    if (modalIcon) modalIcon.classList.add("hidden")
    if (modalTimer) modalTimer.classList.add("hidden")
    if (modalTimerValue) modalTimerValue.textContent = "--"
    if (promptInput) promptInput.value = ""
}

function submitPrompt() {
    if (!currentRequestId || currentMode !== "prompt") return;
    fetch(`https://${GetParentResourceName()}/promptSubmit`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({ requestId: currentRequestId, value: promptInput.value })
    }).catch(() => {});
    closeModal();
}

function cancelPrompt() {
    if (!currentRequestId || currentMode !== "prompt") return;
    fetch(`https://${GetParentResourceName()}/promptCancel`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({ requestId: currentRequestId })
    }).catch(() => {});
    closeModal();
}

window.addEventListener("message", (event) => {
    const data = event.data || {};
    if (data.action === "open") {
        openModal(data);
    } else if (data.action === "close") {
        closeModal();
    }
});

window.addEventListener("keydown", (event) => {
    if (currentMode !== "prompt") return;

    if (event.key === "Escape") {
        event.preventDefault();
        cancelPrompt();
    }
});

if (promptConfirmButton) {
    promptConfirmButton.addEventListener("click", () => submitPrompt());
}

if (promptCancelButton) {
    promptCancelButton.addEventListener("click", () => cancelPrompt());
}
