import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String
  }

  async copy() {
    try {
      // 首先尝试使用 Clipboard API
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(this.textValue)
      } else {
        // 后备方案：创建一个临时文本区域
        const textArea = document.createElement('textarea')
        textArea.value = this.textValue
        textArea.style.position = 'fixed'
        textArea.style.left = '-9999px'
        textArea.style.top = '0'
        document.body.appendChild(textArea)
        textArea.focus()
        textArea.select()
        
        try {
          document.execCommand('copy')
        } finally {
          document.body.removeChild(textArea)
        }
      }
      
      // 显示成功反馈
      const button = this.element
      const originalColor = button.style.color || getComputedStyle(button).color
      button.style.color = '#34D399' // Green color for success
      
      setTimeout(() => {
        button.style.color = originalColor
      }, 1000)
    } catch (err) {
      console.error('Failed to copy text: ', err)
    }
  }
} 