import { Controller } from "stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["canvas", "pageNum", "pageCount", "progress", "bar"]
  static values = { id: String, meetingId: String }

  connect() {
    this.meetingIdValue = this.element.dataset['meetingId']
    this.subscription = consumer.subscriptions.create({ channel: "DocumentsChannel", meeting_id: this.meetingIdValue }, {
      connected: this._connected.bind(this),
      disconnected: this._disconnected.bind(this),
      received: this._received.bind(this)
    })
    this.pdfjsLib = require("pdfjs-dist/webpack")
    this.pdf = null
    this.currentPage = 1
    this.pendingPage = null
    this.rendering = false
    this.scale = parseFloat(this.element.dataset["scale"])
    this.ctx = this.canvasTarget.getContext('2d')

    if(this.hasIdValue) {
      this._initPdf()
    }
  }

  disconnect() {
    this.subscription.unsubscribe()
  }

  prevPage() {
    if (this.currentPage <= 1) {
      return
    }
    this.currentPage--
    this._queueRenderPage(this.currentPage)
  }

  nextPage() {
    if(this.currentPage >= this.pdf.numPages) {
      return
    }
    this.currentPage++
    this._queueRenderPage(this.currentPage)
  }

  firstPage() {
    this.currentPage = 1
    this._queueRenderPage(this.currentPage)
  }

  lastPage() {
    this.currentPage = this.pdf.numPages
    this._queueRenderPage(this.currentPage)
  }

  skipToPage() {
    var newPage = parseInt(this.pageNumTarget.value.trim())
    if (this.currentPage === newPage || !newPage || newPage > this.pdf.numPages) {
      this.pageNumTarget.value = this.currentPage
      return
    }
    this.currentPage = newPage
    this._queueRenderPage(this.currentPage)
  }

  skipOnEnter(event) {
    if (event.keyCode === 13) {
      event.preventDefault()
      this.skipToPage()
    }
  }

  zoomIn() {
    this.scale += 0.25
    this._queueRenderPage(this.currentPage)
  }

  zoomOut() {
    this.scale -= 0.25
    this._queueRenderPage(this.currentPage)
  }

  idValueChanged() {
    if (this.pdfjsLib === undefined) { return }
    this.currentPage = 1
    this.documentRead = false
    this._initPdf()
  }

  _connected() {}

  _disconnected() {}

  _received(data) {
    if (this.idValue === data.document_id) {
      this._initPdf()
    }
  }

  _initTabs() {
    this.tabs = []
    const frames = document.querySelectorAll("div[data-controller='documents--tab']")
    if (!!frames[0]) {
      frames.forEach(frame => {
        const ctrl = this.application.getControllerForElementAndIdentifier(frame, "documents--tab")
        this.tabs.push(ctrl)
      })
    }
    if (!!this.tabs[0]) {
      this.tabs[0].switch()
    }
  }

  _initPdf() {
    if (this.idValue === undefined) { return }
    this.progressTarget.classList.remove("hidden")
    this.canvasTarget.classList.add("hidden")
    var _self = this
    const url = "/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + "/pdf" 
    var loadingTask = this.pdfjsLib.getDocument(url)
    loadingTask.onProgress = (progressData) => {
      var percentLoaded = progressData.loaded * 100 / progressData.total
      this.barTarget.style.width = percentLoaded + "%"
    }
    loadingTask.promise.then(pdfDoc => {
      this.progressTarget.classList.add("hidden")
      this.canvasTarget.classList.remove("hidden")
      this.barTarget.style.width = "0%"
      _self.pdf = pdfDoc
      if (_self.hasPageCountTarget) {
        _self.pageCountTarget.textContent = _self.pdf.numPages
      }
      _self._queueRenderPage(_self.currentPage)
    }).catch(error => {
      this._initTabs()
    })
  }

  _renderPage(num) {
    var _self = this

    this.rendering = true
    this.pdf.getPage(num).then(page => {
      var viewport = page.getViewport({ scale: _self.scale })
      _self.canvasTarget.height = viewport.height
      _self.canvasTarget.width  = viewport.width

      var renderContext = {
        canvasContext: _self.ctx,
        viewport: viewport
      }
      var renderTask = page.render(renderContext)

      renderTask.promise.then(() => {
        _self.rendering = false
        if (_self.pendingPage !== null) {
          _self._renderPage(_self.pendingPage)
          _self.pendingPage = null
        } else if (_self.currentPage == _self.pdf.numPages && !_self.documentRead) {
          _self.documentRead = true
          fetch("/documents/" + this.idValue + "/mark_as_read")
        }
      })
    })
    if (this.hasPageNumTarget) {
      this.pageNumTarget.value = num
    }
  }

  _queueRenderPage(num) {
    if (this.rendering) {
      this.pendingPage = num
    } else {
      this._renderPage(num)
    }
  }
}