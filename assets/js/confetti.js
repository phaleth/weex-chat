import JSConfetti from "../vendor/js-confetti.min.js";

class Confetti {
  constructor() {
    if (Confetti._instance) {
      return Confetti._instance;
    }
    Confetti._instance = this;

    this.confetti = new JSConfetti();

    this.opts = {
      confettiRadius: 5,
      confettiNumber: 300,
    };

    this.priorTarget = null;
  }

  explosion(e) {
    if (e.target !== this.priorTarget) this.confetti.addConfetti(this.opts);
    this.priorTarget = e.target;
  }
}

export default confetti = new Confetti();
