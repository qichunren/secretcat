import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // 5秒后自动隐藏消息
    setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  dismiss() {
    // 添加淡出动画
    this.element.classList.add('opacity-0', 'translate-y-[-10px]')
    
    // 等待动画完成后移除元素
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  // 点击关闭按钮时调用
  close() {
    this.dismiss()
  }
} 