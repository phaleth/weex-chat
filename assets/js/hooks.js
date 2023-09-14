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
      this.handleEvent("hooray", () => {
        confetti.explosion();
      });
      this.handleEvent("clear-chat", () => {
        const container = document.getElementById("messages-container");
        while (container.firstChild) {
          container.removeChild(container.lastChild);
        }
      });
      document
        .querySelector(".wxch-user-menu")
        .addEventListener("click", userMenuClickHandler);
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
