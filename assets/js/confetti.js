import JSConfetti from "../vendor/js-confetti.min.js";

class Confetti {
  constructor() {
    if (Confetti._instance) {
      return Confetti._instance;
    }
    Confetti._instance = this;

    this.confetti = new JSConfetti();
  }
}

export const confettiExplosion = () => {
  const confetti = new Confetti().confetti;
  confetti.addConfetti({
    confettiRadius: 5,
    confettiNumber: 300,
  });
};
