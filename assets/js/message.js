class Message {
  constructor() {
    if (Message._instance) {
      return Message._instance;
    }
    Message._instance = this;
  }

  submitForm(el) {
    el.form.dispatchEvent(
      new Event("submit", { bubbles: true, cancelable: true })
    );
    el.value = "";
  }

  sendOnEnter(e) {
    if (e.key == "Enter") this.submitForm(e.target);
  }

  edit(e) {
    let textEl = e.target.previousElementSibling;
    const priorTextHTML = textEl.outerHTML;
    const formHTML = `<form class="flex-none" id="mod-msg-form" phx-submit="msg-mod-submit">
        <span class="wxch-hide absolute overflow-hidden whitespace-pre"></span>
        <input
          class="wxch-remove-box-shadow px-0 h-5 border-none bg-gray-200 dark:bg-black
            text-black dark:text-gray-300 placeholder-gray-600 dark:placeholder-gray-400
            font-mono text-sm"
          aria-label="Edit message"
          type="text"
          phx-value-id=${e.target.id}
          name="msg"
          value="${textEl.textContent}"
          phx-blur="mod-msg"
          />
        <input type="hidden" name="id" value=${e.target.id} />
      </form>`;
    textEl.insertAdjacentHTML("beforeBegin", formHTML);
    const formEl = textEl.previousElementSibling;
    textEl.remove();
    const inputEl = formEl.querySelector("input");

    const hide = formEl.querySelector(".wxch-hide");
    hide.textContent = inputEl.value;
    inputEl.style.width = hide.offsetWidth + "px";
    inputEl.addEventListener("input", () => {
      hide.textContent = inputEl.value;
      inputEl.style.width = hide.offsetWidth + "px";
    });

    inputEl.focus();
    inputEl.setSelectionRange(-1, -1);

    const modEl = formEl.nextElementSibling;
    const delEl = modEl.nextElementSibling;
    modEl.classList.remove("group-hover:inline");
    delEl.classList.remove("group-hover:inline");

    const focusOutHandler = function () {
      formEl.insertAdjacentHTML("beforeBegin", priorTextHTML);
      textEl = formEl.previousElementSibling;
      textEl.textContent = inputEl.value;
      formEl.remove();
      modEl.classList.add("group-hover:inline");
      delEl.classList.add("group-hover:inline");

      this.removeEventListener("focusout", focusOutHandler);
    };

    inputEl.addEventListener("focusout", focusOutHandler);
  }

  delete(e) {
    const textWithIcons = e.target.parentElement;
    const splitter = textWithIcons.previousElementSibling;
    const from = splitter.previousElementSibling;
    const time = from.previousElementSibling;
    textWithIcons.remove();
    splitter.remove();
    from.remove();
    time.remove();
  }

  toggleMessagesVisibility(channelName) {
    document.querySelectorAll(".wxch-msg").forEach((el) => {
      if (el.classList.contains(`wxch-msg-${channelName}`)) {
        el.classList.remove("hidden");
      } else {
        el.classList.add("hidden");
      }
    });
  }
}

export default new Message();
