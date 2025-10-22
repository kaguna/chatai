import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { messagesContainer: String }
  
  connect() {
    console.log("Message form controller connected")
    console.log("Messages container selector:", this.messagesContainerValue)
  }
  
  submit(event) {
    console.log("Submit method called")
    const form = event.target
    const formData = new FormData(form)
    const message = formData.get("message")
    
    console.log("Message:", message)
    console.log("Input target:", this.inputTarget)
    console.log("Messages container selector:", this.messagesContainerValue)
    
    if (!message.trim()) {
      event.preventDefault()
      return
    }
    
    // Create user message element and add to top
    this.addUserMessageToTop(message)
    
    // Clear the input
    this.clearInput()
    
    // Let the form submit normally to the server
    // Don't prevent default - let Rails handle the server request
  }
  
  addUserMessageToTop(message) {
    const messagesContainer = document.querySelector(this.messagesContainerValue)
    console.log("Messages container element:", messagesContainer)
    
    if (!messagesContainer) {
      console.error("Messages container not found with selector:", this.messagesContainerValue)
      return
    }
    
    const userMessageElement = this.createUserMessageElement(message)
    
    // Insert at the end of messages container (which appears at top due to flex-col-reverse)
    messagesContainer.appendChild(userMessageElement)
    
    // Scroll to bottom to show the new message
    messagesContainer.scrollTop = messagesContainer.scrollHeight
    console.log("Message added, scrolled to bottom")
  }
  
  createUserMessageElement(message) {
    const messageDiv = document.createElement('div')
    messageDiv.className = 'message flex justify-end'
    messageDiv.innerHTML = `
      <div class="max-w-xs lg:max-w-md px-4 py-2 rounded-lg bg-blue-600 text-white">
        <div class="text-sm">
          ${message.replace(/\n/g, '<br>')}
        </div>
        <div class="text-xs opacity-75 mt-1">
          ${new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
        </div>
      </div>
    `
    return messageDiv
  }
  
  clearInput() {
    console.log("Clearing input, current value:", this.inputTarget.value)
    this.inputTarget.value = ''
    this.inputTarget.focus()
    console.log("Input cleared and focused")
  }
}
