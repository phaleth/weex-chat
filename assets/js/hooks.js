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
  msgSubmit: {
    mounted() {
      this.el.addEventListener("keydown", (e) => {
        if (e.key == "Enter") {
          this.el.form.dispatchEvent(
            new Event("submit", { bubbles: true, cancelable: true })
          );
          this.el.value = "";
        }
      });
    },
  },
  delMsg: {
    mounted() {
      this.el.addEventListener("click", () => {
        const text = this.el.parentElement;
        const splitter = text.previousElementSibling;
        const from = splitter.previousElementSibling;
        const time = from.previousElementSibling;
        text.remove();
        splitter.remove();
        from.remove();
        time.remove();
      });
    },
  },
};
