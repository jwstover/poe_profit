export const TypeAheadSelect = {
  mounted() {
    this.initializeElements()
    this.setupEventListeners()
    this.allOptions = this.parseOptions()
  },

  initializeElements() {
    this.hiddenInput = this.el.querySelector('[data-hidden-input]')
    this.displayButton = this.el.querySelector('[data-display-button]')
    this.displayText = this.el.querySelector('[data-display-text]')
    this.searchInput = this.el.querySelector('[data-search-input]')
    this.optionsList = this.el.querySelector('[data-options-list]')
    this.dropdownContainer = this.el.querySelector('[data-dropdown]')
    this.isOpen = false
  },

  parseOptions() {
    const options = []
    this.optionsList.querySelectorAll('[data-option]').forEach(option => {
      options.push({
        value: option.dataset.value,
        label: option.textContent.trim(),
        element: option
      })
    })
    return options
  },

  setupEventListeners() {
    // Toggle dropdown on button click
    this.displayButton.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.toggleDropdown()
    })

    // Search input changes
    this.searchInput.addEventListener('input', (e) => {
      this.filterOptions(e.target.value)
    })

    // Prevent search input clicks from closing dropdown
    this.searchInput.addEventListener('click', (e) => {
      e.stopPropagation()
    })

    // Option selection
    this.optionsList.addEventListener('click', (e) => {
      const option = e.target.closest('[data-option]')
      if (option && !option.hasAttribute('disabled')) {
        this.selectOption(option.dataset.value, option.textContent.trim())
      }
    })

    // Keyboard navigation
    this.searchInput.addEventListener('keydown', (e) => {
      this.handleKeyboard(e)
    })

    // Close dropdown when clicking outside
    document.addEventListener('click', (e) => {
      if (this.isOpen && !this.el.contains(e.target)) {
        this.closeDropdown()
      }
    })

    // Close on escape
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.isOpen) {
        this.closeDropdown()
      }
    })
  },

  toggleDropdown() {
    if (this.isOpen) {
      this.closeDropdown()
    } else {
      this.openDropdown()
    }
  },

  openDropdown() {
    this.isOpen = true
    this.dropdownContainer.classList.remove('hidden')
    this.searchInput.value = ''
    this.filterOptions('')
    this.searchInput.focus()
    this.highlightedIndex = -1
  },

  closeDropdown() {
    this.isOpen = false
    this.dropdownContainer.classList.add('hidden')
    this.searchInput.value = ''
    this.displayButton.focus()
  },

  filterOptions(searchTerm) {
    const normalizedSearch = searchTerm.toLowerCase().trim()

    this.allOptions.forEach(option => {
      const normalizedLabel = option.label.toLowerCase()
      const matches = normalizedLabel.includes(normalizedSearch)

      if (matches) {
        option.element.classList.remove('hidden')
      } else {
        option.element.classList.add('hidden')
      }
    })

    // Reset highlighted index when filtering
    this.highlightedIndex = -1
    this.updateHighlight()
  },

  selectOption(value, label) {
    this.hiddenInput.value = value
    this.displayText.textContent = label

    // Trigger change event for form validation
    this.hiddenInput.dispatchEvent(new Event('change', { bubbles: true }))

    this.closeDropdown()
  },

  handleKeyboard(e) {
    const visibleOptions = this.allOptions.filter(opt => !opt.element.classList.contains('hidden'))

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        this.highlightedIndex = Math.min(this.highlightedIndex + 1, visibleOptions.length - 1)
        this.updateHighlight()
        this.scrollToHighlighted()
        break

      case 'ArrowUp':
        e.preventDefault()
        this.highlightedIndex = Math.max(this.highlightedIndex - 1, -1)
        this.updateHighlight()
        this.scrollToHighlighted()
        break

      case 'Enter':
        e.preventDefault()
        if (this.highlightedIndex >= 0 && visibleOptions[this.highlightedIndex]) {
          const option = visibleOptions[this.highlightedIndex]
          this.selectOption(option.value, option.label)
        }
        break

      case 'Escape':
        e.preventDefault()
        this.closeDropdown()
        break
    }
  },

  updateHighlight() {
    const visibleOptions = this.allOptions.filter(opt => !opt.element.classList.contains('hidden'))

    // Remove all highlights
    this.allOptions.forEach(opt => {
      opt.element.classList.remove('bg-base-200')
    })

    // Add highlight to current index
    if (this.highlightedIndex >= 0 && visibleOptions[this.highlightedIndex]) {
      visibleOptions[this.highlightedIndex].element.classList.add('bg-base-200')
    }
  },

  scrollToHighlighted() {
    const visibleOptions = this.allOptions.filter(opt => !opt.element.classList.contains('hidden'))
    if (this.highlightedIndex >= 0 && visibleOptions[this.highlightedIndex]) {
      const element = visibleOptions[this.highlightedIndex].element
      element.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
    }
  }
}
