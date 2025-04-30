import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String
  }

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      // 添加复制成功的视觉反馈
      const notification = document.createElement('div');
      notification.className = 'fixed left-1/2 top-4 bg-indigo-600/90 backdrop-blur-sm text-white px-6 py-3 rounded-xl shadow-lg transform transition-all duration-300 z-[9999] flex items-center gap-2';
      notification.style.transform = 'translate(-50%, -150%)';
      
      // 添加成功图标
      const icon = document.createElement('svg');
      icon.className = 'w-5 h-5 text-indigo-200 flex-shrink-0';
      icon.setAttribute('fill', 'none');
      icon.setAttribute('stroke', 'currentColor');
      icon.setAttribute('viewBox', '0 0 24 24');
      icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>';
      
      notification.appendChild(icon);
      notification.appendChild(document.createTextNode('已复制到剪贴板'));
      
      document.body.appendChild(notification);
      
      // 显示通知
      requestAnimationFrame(() => {
        notification.style.transform = 'translate(-50%, 0)';
        notification.style.opacity = '1';
      });
      
      // 3秒后移除通知
      setTimeout(() => {
        notification.style.transform = 'translate(-50%, -150%)';
        notification.style.opacity = '0';
        notification.addEventListener('transitionend', () => {
          notification.remove();
        }, { once: true });
      }, 3000);
    }).catch((err) => {
      console.error('复制失败:', err);
    });
  }
} 