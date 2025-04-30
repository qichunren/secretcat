import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "title"]
  static values = {
    title: String
  }

  connect() {
    // 当 controller 连接时，设置标题
    if (this.hasTitleTarget && this.hasTitleValue) {
      this.titleTarget.textContent = this.titleValue
    }
  }

  showModal(event) {
    event.preventDefault()
    this.modalTarget.classList.remove('hidden')
  }

  hideModal() {
    this.modalTarget.classList.add('hidden')
  }

  confirm(event) {
    // 隐藏对话框
    this.hideModal()
    
    // 提交删除表单
    this.element.requestSubmit()
  }

  // 点击模态框背景时关闭
  backgroundClick(event) {
    if (event.target === this.modalTarget) {
      this.hideModal()
    }
  }
} 