import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "mainNavMenu", "mainNavBurger" ]

  initialize() {
    document.addEventListener("click", this.closeMenu.bind(this));
  }

  closeMenu(e) {
    if (!this.hasClass(e.target, "navbar")) {
      this.mainNavMenuTarget.classList.remove('is-active');
      this.mainNavBurgerTarget.classList.remove('is-active');
    }
  }

  toggle() {
    this.mainNavMenuTarget.classList.toggle('is-active');
    this.mainNavBurgerTarget.classList.toggle('is-active');
  }

  /**
   * Searches through the DOM tree to see if a class or it's parent has
   * a given class.
   *
   * @param {element} element The element to start with
   * @param {element} className The class name to search for
   */
  hasClass(element, className) {
    do {
      if (element.classList && element.classList.contains(className)) {
        return true;
      }
      element = element.parentNode;
    } while (element);
    return false;
  }
}
