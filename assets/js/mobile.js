export const refreshSidebars = () => {
  const chansListEl = document.querySelector(".wxch-chans-list");
  const chansIcoBurgerEl = document.querySelector(".wxch-chans-ico-hamburger");
  const chansIcoCloseEl = document.querySelector(".wxch-chans-ico-close");
  const chansBtnEl = document.querySelector(".wxch-chans-btn");
  if (chansBtnEl) {
    chansBtnEl.onclick = () => {
      chansListEl.classList.toggle("hidden");
      chansIcoBurgerEl.classList.toggle("hidden");
      chansIcoCloseEl.classList.toggle("hidden");
    };
  }

  const usersListEl = document.querySelector(".wxch-users-list");
  const usersIcoBurgerEl = document.querySelector(".wxch-users-ico-hamburger");
  const usersIcoCloseEl = document.querySelector(".wxch-users-ico-close");
  const usersBtnEl = document.querySelector(".wxch-users-btn");
  if (usersBtnEl) {
    usersBtnEl.onclick = () => {
      usersListEl.classList.toggle("hidden");
      usersIcoBurgerEl.classList.toggle("hidden");
      usersIcoCloseEl.classList.toggle("hidden");
    };
  }

  let resizeTimeout;
  window.onresize = () => {
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(() => {
      if (window.innerWidth > 639) {
        if (chansListEl) chansListEl.classList.toggle("hidden");
        if (chansIcoBurgerEl) chansIcoBurgerEl.classList.toggle("hidden");
        if (chansIcoCloseEl) chansIcoCloseEl.classList.toggle("hidden");
        if (usersListEl) usersListEl.classList.toggle("hidden");
        if (usersIcoBurgerEl) usersIcoBurgerEl.classList.toggle("hidden");
        if (usersIcoCloseEl) usersIcoCloseEl.classList.toggle("hidden");
      }
    }, 250);
  };
};

export const userMenuClickHandler = (e) => {
  e.target.nextElementSibling.classList.remove("hidden");
};
