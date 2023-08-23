const toLocalTime = (textContent) => {
  const date = new Date(textContent.replace(/\.\d+Z$/, ""));
  date.setHours(date.getHours() - new Date().getTimezoneOffset() / 60);
  return (
    String(date.getHours()).padStart(2, "0") +
    ":" +
    String(date.getMinutes()).padStart(2, "0")
  );
};

export const hooks = {
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
  localTime: {
    mounted() {
      this.updated();
    },
    updated() {
      this.el.textContent = toLocalTime(this.el.textContent);
    },
  },
  currentTime: {
    mounted() {
      this.el.textContent = toLocalTime(this.el.textContent);
      this.handleEvent("tick", ({ time }) => {
        this.el.textContent = toLocalTime(time);
      });
    },
  },
};
