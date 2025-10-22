import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  
  connect() {
    console.log("Auto-scroll controller connected")
    // Scroll to bottom on initial load to show latest messages
    this.scrollToBottom()
    
    // Listen for custom message events
    this.containerTarget.addEventListener("message-added", this.messageAdded.bind(this))
    this.containerTarget.addEventListener("message-updated", this.messageAdded.bind(this))
  }
  
  disconnect() {
    // Clean up event listeners
    if (this.hasContainerTarget) {
      this.containerTarget.removeEventListener("message-added", this.messageAdded.bind(this))
      this.containerTarget.removeEventListener("message-updated", this.messageAdded.bind(this))
    }
  }
  
  scrollToBottom() {
    if (this.hasContainerTarget) {
      this.containerTarget.scrollTop = this.containerTarget.scrollHeight
      console.log("Scrolled to bottom")
    }
  }
  
  scrollToTop() {
    if (this.hasContainerTarget) {
      this.containerTarget.scrollTop = 0
      console.log("Scrolled to top")
    }
  }
  
  // This method will be called when new messages are added via Turbo Streams
  messageAdded() {
    // Use setTimeout to ensure the DOM has been updated
    setTimeout(() => {
      this.scrollToBottom()
    }, 10)
  }
  
  // This method will be called when the container content changes
  containerChanged() {
    this.scrollToBottom()
  }
}
