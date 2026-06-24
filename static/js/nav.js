// Navbar scroll effect: solidify the bar once the user scrolls past the hero top.
const nav = document.querySelector('nav');
window.addEventListener('scroll', () => {
  if (window.scrollY > 50) {
    nav.classList.add('shadow-md', 'bg-white');
    nav.classList.remove('bg-white/90');
  } else {
    nav.classList.remove('shadow-md', 'bg-white');
    nav.classList.add('bg-white/90');
  }
});
