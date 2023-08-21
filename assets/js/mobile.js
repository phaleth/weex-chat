export const refreshSidebars = () => {
  const chansListEl = document.querySelector(".wxch-chans-list");
  const chansIcoBurgerEl = document.querySelector(".wxch-chans-ico-hamburger");
  const chansIcoCloseEl = document.querySelector(".wxch-chans-ico-close");
  document.querySelector(".wxch-chans-btn").onclick = () => {
    chansListEl.classList.toggle("hidden");
    chansIcoBurgerEl.classList.toggle("hidden");
    chansIcoCloseEl.classList.toggle("hidden");
  };

  const usersListEl = document.querySelector(".wxch-users-list");
  const usersIcoBurgerEl = document.querySelector(".wxch-users-ico-hamburger");
  const usersIcoCloseEl = document.querySelector(".wxch-users-ico-close");
  document.querySelector(".wxch-users-btn").onclick = () => {
    usersListEl.classList.toggle("hidden");
    usersIcoBurgerEl.classList.toggle("hidden");
    usersIcoCloseEl.classList.toggle("hidden");
  };

  let resizeTimeout;
  window.onresize = () => {
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(() => {
      if (window.innerWidth > 639) {
        chansListEl.classList.toggle("hidden");
        chansIcoBurgerEl.classList.toggle("hidden");
        chansIcoCloseEl.classList.toggle("hidden");
        usersListEl.classList.toggle("hidden");
        usersIcoBurgerEl.classList.toggle("hidden");
        usersIcoCloseEl.classList.toggle("hidden");
      }
    }, 250);
  };
};
