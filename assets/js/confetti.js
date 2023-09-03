class Confetti {
  constructor() {
    if (Confetti._instance) {
      return Confetti._instance;
    }
    Confetti._instance = this;

    this.opts = {
      confettiRadius: 5,
      confettiNumber: 300,
    };

    this.priorTarget = null;
  }

  explosion(e) {
    if (e.target !== this.priorTarget) {
      import("../vendor/js-confetti.min.js").then(({ default: JSConfetti }) => {
        new JSConfetti().addConfetti(this.opts);
      });
    }
    this.priorTarget = e.target;
  }
}

export default new Confetti();
