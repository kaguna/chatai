import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay", "openButton", "closeButton"]
  static values = { isOpen: Boolean }

  connect() {
    // Close panel on window resize to desktop size
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
    
    // Close panel when conversation links are clicked on mobile
    this.handleConversationClick = this.handleConversationClick.bind(this)
    this.setupConversationListeners()
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
    this.removeConversationListeners()
  }

  open() {
    this.panelTarget.classList.remove('-translate-x-full')
    this.panelTarget.classList.add('translate-x-0')
    this.overlayTarget.classList.remove('hidden')
    this.isOpenValue = true
  }

  close() {
    this.panelTarget.classList.add('-translate-x-full')
    this.panelTarget.classList.remove('translate-x-0')
    this.overlayTarget.classList.add('hidden')
    this.isOpenValue = false
  }

  toggle() {
    if (this.isOpenValue) {
      this.close()
    } else {
      this.open()
    }
  }

  handleResize() {
    // Close panel when resizing to desktop size (lg breakpoint)
    if (window.innerWidth >= 1024) {
      this.close()
    }
  }

  setupConversationListeners() {
    const conversationLinks = document.querySelectorAll('#conversations a')
    conversationLinks.forEach(link => {
      link.addEventListener('click', this.handleConversationClick)
    })
  }

  removeConversationListeners() {
    const conversationLinks = document.querySelectorAll('#conversations a')
    conversationLinks.forEach(link => {
      link.removeEventListener('click', this.handleConversationClick)
    })
  }

  handleConversationClick(event) {
    // Close panel when a conversation is selected on mobile
    if (window.innerWidth < 1024) {
      this.close()
    }
  }
}
