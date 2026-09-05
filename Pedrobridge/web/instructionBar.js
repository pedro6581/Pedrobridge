const STYLE_MAP = new Set(["red", "green"]);

const normalizeKeys = (keys) => {
    if (Array.isArray(keys)) {
        return keys.map((key) => String(key));
    }

    if (typeof keys === "string") {
        return [keys];
    }

    return [];
};

const normalizeStyle = (style) => {
    if (!style || typeof style !== "string") {
        return "default";
    }

    const normalized = style.toLowerCase();
    if (!normalized || normalized === "default") {
        return "default";
    }

    return STYLE_MAP.has(normalized) ? normalized : "default";
};

const normalizeBinds = (binds) => {
    if (!binds) {
        return [];
    }

    const bindList = Array.isArray(binds) ? binds : [binds];

    return bindList.map((bind) => {
        const keys = normalizeKeys(bind?.keys);
        const desc = typeof bind?.desc === "string" ? bind.desc : "";
        const style = normalizeStyle(bind?.style);

        return {
            keys,
            desc,
            style
        };
    });
};

const createKeycap = (key, style) => {
    const keycap = document.createElement("span");
    keycap.classList.add("instruction-keycap");

    const normalizedKey = String(key);
    if (normalizedKey.length > 2) {
        keycap.classList.add("instruction-keycap--long");
    }

    if (style === "red") {
        keycap.classList.add("instruction-keycap--red");
    }

    if (style === "green") {
        keycap.classList.add("instruction-keycap--green");
    }

    keycap.textContent = normalizedKey;
    return keycap;
};

const renderBinds = (container, binds) => {
    container.innerHTML = "";

    if (!binds.length) {
        container.classList.remove("is-visible");
        container.setAttribute("aria-hidden", "true");
        return;
    }

    binds.forEach((bind) => {
        const chip = document.createElement("div");
        chip.classList.add("instruction-chip");

        const keysWrapper = document.createElement("div");
        keysWrapper.classList.add("instruction-keys");

        bind.keys.forEach((key) => {
            keysWrapper.appendChild(createKeycap(key, bind.style));
        });

        const desc = document.createElement("span");
        desc.classList.add("instruction-desc");
        desc.textContent = bind.desc;

        chip.appendChild(keysWrapper);
        chip.appendChild(desc);
        container.appendChild(chip);
    });

    container.classList.add("is-visible");
    container.setAttribute("aria-hidden", "false");
};

(() => {
    const instructionBar = document.querySelector("#instruction-bar");

    if (!instructionBar) {
        return;
    }

    window.addEventListener("message", (event) => {
        const data = event.data;
        if (!data || !data.action) {
            return;
        }

        if (data.action === "openInstructionKeys") {
            const binds = normalizeBinds(data.binds);
            renderBinds(instructionBar, binds);
        }

        if (data.action === "closeInstructionKeys") {
            instructionBar.classList.remove("is-visible");
            instructionBar.setAttribute("aria-hidden", "true");
            instructionBar.innerHTML = "";
        }
    });
})();
