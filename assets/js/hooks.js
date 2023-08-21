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
};
