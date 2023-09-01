const submitForm = (el) => {
  el.form.dispatchEvent(
    new Event("submit", { bubbles: true, cancelable: true })
  );
  el.value = "";
};

export default hooks = {
  ping: {
    mounted() {
      let count = 0;
      this.handleEvent("tick", () => {
        if (count >= 5) {
          const beforeTime = new Date().getTime();
          this.pushEvent("ping", {}, (_res) => {
            this.el.innerText = `${(new Date().getTime() - beforeTime) / 1000}`;
          });
          count = 0;
        }
        count++;
      });
    },
  },
  timeOffset: {
    mounted() {
      this.pushEvent("time-zone", {
        offset: -new Date().getTimezoneOffset() / 60,
      });
    },
  },
  currentTime: {
    mounted() {
      this.handleEvent("tick", ({ time }) => {
        this.el.textContent = time;
      });
    },
  },
  setupLists: {
    mounted() {
      this.pushEvent("setup-lists", {});
    },
  },
  msgSubmit: {
    mounted() {
      this.el.addEventListener("keydown", (e) => {
        if (e.key == "Enter") submitForm(this.el);
      });
    },
  },
  modMsg: {
    mounted() {
      this.el.addEventListener("click", () => {
        let textEl = this.el.previousElementSibling;
        const priorTextHTML = textEl.outerHTML;
        const formHTML = `<form class="flex-none" id="mod-msg-form" phx-submit="msg-edit-submit">
          <span class="wxch-hide absolute overflow-hidden whitespace-pre"></span>
          <input
            class="wxch-remove-box-shadow px-0 h-5 border-none bg-gray-200 dark:bg-black
              text-black dark:text-gray-300 placeholder-gray-600 dark:placeholder-gray-400
              font-mono text-sm"
            aria-label="Edit message"
            type="text"
            phx-value-id=${this.el.id}
            name="msg"
            value="${textEl.textContent}"
            phx-blur="mod-msg"
            />
          <input type="hidden" name="id" value=${this.el.id} />
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

        inputEl.addEventListener("focusout", () => {
          formEl.insertAdjacentHTML("beforeBegin", priorTextHTML);
          textEl = formEl.previousElementSibling;
          textEl.textContent = inputEl.value;
          formEl.remove();
          modEl.classList.add("group-hover:inline");
          delEl.classList.add("group-hover:inline");
        });
      });
    },
  },
  delMsg: {
    mounted() {
      this.el.addEventListener("click", () => {
        const textWithIcons = this.el.parentElement;
        const splitter = textWithIcons.previousElementSibling;
        const from = splitter.previousElementSibling;
        const time = from.previousElementSibling;
        textWithIcons.remove();
        splitter.remove();
        from.remove();
        time.remove();
      });
    },
  },
};
