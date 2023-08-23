export const hooks = {
  ping: {
    mounted() {
      this.timer = setInterval(() => {
        const beforeTime = new Date().getTime();
        this.pushEvent("ping", {}, (_res) => {
          this.el.innerText = `${(new Date().getTime() - beforeTime) / 1000}`;
        });
      }, 5000);
    },
    destroyed() {
      clearInterval(this.timer);
    },
  },
  localTime: {
    mounted() {
      this.updated();
    },
    updated() {
      const date = new Date(this.el.textContent.replace(/.\d+Z$/, ""));
      date.setHours(date.getHours() - new Date().getTimezoneOffset() / 60);
      this.el.textContent =
        String(date.getHours()).padStart(2, "0") +
        ":" +
        String(date.getMinutes()).padStart(2, "0");
    },
  },
};
