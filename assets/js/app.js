import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let Hooks = {};

Hooks.CopyButton = {
  mounted() {
    let { copyFrom } = this.el.dataset;
    const self = this;
    this.el.addEventListener("click", (ev) => {
      console.log(copyFrom);
      ev.preventDefault();
      let shortUrl = document.querySelector(copyFrom).href;
      navigator.clipboard.writeText(shortUrl).then(() => {
        self.pushEvent("url-copied", {});
      });
    });
  },
};

Hooks.SubmitButtonEnablement = {
  mounted() {
    const submitButton = document.querySelector("#shorten-button");
    const targetUrlInput = document.querySelector("#target-url");
    console.log(targetUrlInput);

    this.el.addEventListener("input", () => {
      submitButton.disabled = targetUrlInput.value === "";
    });

    const form = this.el.closest("form");
    form.addEventListener("submit", () => {
      submitButton.disabled = true;
    });
  },
};

Hooks.AutoHideFlash = {
  mounted() {
    const self = this;

    setTimeout(() => {
      self.el.addEventListener("animationend", () => {
        self.el.remove();
        self.pushEvent("lv:clear-flash", { key: self.el.dataset.key });
      });

      self.el.classList.add("animate-rollup");
    }, 3000);
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
