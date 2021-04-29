import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { url: String }

  connect() {
    this.pdfjsLib = require("pdfjs-dist/webpack")
    this.pdf = null
    this.currentPage = 1
    this.pendingPage = null
    this.rendering = false
    this.scale = parseFloat(this.element.dataset["scale"])
    this.ctx = this.canvasTarget.getContext('2d')
    
    this._initPdf()
  }

  _initPdf() {
    if (this.urlValue === undefined) { return }
    var _self = this
    this.pdfjsLib.getDocument(this.urlValue).promise.then(pdfDoc => {
      _self.pdf = pdfDoc
      if (_self.hasPageCountTarget) {
        _self.pageCountTarget.textContent = _self.pdf.numPages
      }
      _self._queueRenderPage(_self.currentPage)
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
        }
      })
    })
  }

  _queueRenderPage(num) {
    if (this.rendering) {
      this.pendingPage = num
    } else {
      this._renderPage(num)
    }
  }
}