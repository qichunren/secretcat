import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleScroll()
    window.addEventListener('scroll', this.handleScroll.bind(this))
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll.bind(this))
  }

  handleScroll() {
    const scrolled = window.scrollY > 20
    
    if (scrolled) {
      // 滚动后：添加半透明背景和模糊效果
      this.element.classList.add('bg-slate-900/80', 'backdrop-blur-md', 'shadow-lg')
      this.element.classList.remove('bg-transparent')
    } else {
      // 顶部：完全透明
      this.element.classList.remove('bg-slate-900/80', 'backdrop-blur-md', 'shadow-lg')
      this.element.classList.add('bg-transparent')
    }
  }
}

