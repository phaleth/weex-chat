import message from "./message";
import confetti from "./confetti";
import { userMenuClickHandler } from "./mobile";

export default {
  ping: {
    mounted() {
      let count = 0;
      this.handleEvent("tick", () => {
        if (count >= 5) {
          const beforeTime = new Date().getTime();
          this.pushEvent("ping", {}, (_res) => {
            const lag = new Date().getTime() - beforeTime;
            message.lag = lag + 25;
            this.el.innerText = `${lag / 1000}`;
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
      this.handleEvent("hooray", () => confetti.explosion());
      this.handleEvent("change-chan", ({ channel }) =>
        message.toggleMessagesVisibility(channel)
      );
      document
        .querySelector(".wxch-user-menu")
        .addEventListener("click", userMenuClickHandler);
      this.handleEvent("scroll", () => message.scrollToBottom());
    },
    destroyed() {
      document
        .querySelector(".wxch-user-menu")
        .removeEventListener("click", userMenuClickHandler);
    },
  },
  msgSubmit: {
    mounted() {
      this.el.addEventListener("keydown", (e) => message.sendOnEnter(e));
    },
    destroyed() {
      this.el.removeEventListener("keydown", (e) => message.sendOnEnter(e));
    },
  },
  modMsg: {
    mounted() {
      this.el.addEventListener("click", (e) => message.edit(e));
    },
    destroyed() {
      this.el.addEventListener("click", (e) => message.edit(e));
    },
  },
  delMsg: {
    mounted() {
      this.el.addEventListener("click", (e) => message.delete(e));
    },
    destroyed() {
      this.el.removeEventListener("click", (e) => message.delete(e));
    },
  },
};
