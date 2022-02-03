import { Controller } from "stimulus"
import consumer from "channels/consumer"
import PDFJSExpress from '@pdftron/pdfjs-express'

export default class extends Controller {
  // static targets = ["canvas", "pageNum", "pageCount", "progress", "bar", "placeholder", "controls"]
  static values = { id: String, meetingId: String }

  connect() {
    this.meetingIdValue = this.element.dataset['meetingId']
    this.subscription = consumer.subscriptions.create({ channel: "DocumentsChannel", meeting_id: this.meetingIdValue }, {
      connected: this._connected.bind(this),
      disconnected: this._disconnected.bind(this),
      received: this._received.bind(this)
    })
    this.pdf = null
    this.currentPage = 1
    this.pendingPage = null
    this.rendering = false

    if (this.hasIdValue) {
      this._initPdf()
    }
  }

  disconnect() {
    this.subscription.unsubscribe()
  }

  idValueChanged() {
    if (this.meetingIdValue && this.idValue) {
      this.currentPage = 1
      this.documentRead = false
      this._initPdf()
    }
  }

  _connected() {}

  _disconnected() {}

  _received(data) {
    if (this.idValue === data.document_id) {
      this._initPdf()
    }
  }

  // _initTabs() {
  //   this.tabs = []
  //   const frames = document.querySelectorAll("div[data-controller='documents--tab']")
  //   if (!!frames[0]) {
  //     frames.forEach(frame => {
  //       const ctrl = this.application.getControllerForElementAndIdentifier(frame, "documents--tab")
  //       this.tabs.push(ctrl)
  //     })
  //   }
  //   if (!!this.tabs[0]) {
  //     this.tabs[0].switch()
  //   }
  // }

  _initPdf() {
    // FIXME:
    this.element.innerHTML = '<div id="viewer" class="h-full"></div>'

    const url = "/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + "/pdf"
    console.debug('Load', url)
    PDFJSExpress({
      path: '/pdftron',
      initialDoc: url,
      disabledElements: [
        'leftPanelButton',
        'leftPanel',
        'viewControlsButton',
        'selectToolButton',
        'panToolButton',
        'toolbarGroup-View',
        'toolbarGroup-Annotate',
        'toolbarGroup-Shapes',
        'toolbarGroup-Insert',
        'toolbarGroup-FillAndSign',
        'ribbonsDropdown',
        'searchButton',
        'searchPanel',
        'searchPanelResizeBar',
        'toggleNotesButton',
        'notesPanel',
        'notesPanelResizeBar',
        'menuButton',
        'toolsHeader',
        'annotationStyleEditButton',
        'linkButton'
      ]
    }, document.getElementById('viewer')).then(instance => {
      const {
        docViewer,
        annotManager: annotationManager,
        Core: {
          Annotations
        }
      } = instance

      const createSignHereBox = ({ pageNumber, x, y, width, height, name }) => {
        // create a form field
        const field = new Annotations.Forms.Field(name, { type: 'Sig' })

        // create a widget annotation
        const widgetAnnot = new Annotations.SignatureWidgetAnnotation(field, {
          appearance: '_DEFAULT',
          appearances: {
            _DEFAULT: {
              Normal: {
                data:
                  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjEuMWMqnEsAAAANSURBVBhXY/j//z8DAAj8Av6IXwbgAAAAAElFTkSuQmCC',
                offset: {
                  x: x,
                  y: y,
                },
              },
            },
          },
        })

        // set position and size
        widgetAnnot.PageNumber = pageNumber;
        widgetAnnot.X = x;
        widgetAnnot.Y = y;
        widgetAnnot.Width = width;
        widgetAnnot.Height = height;

        // add the form field and widget annotation
        annotationManager.getFieldManager().addField(field)
        annotationManager.addAnnotation(widgetAnnot)
        annotationManager.drawAnnotationsFromList([widgetAnnot])
      }

      docViewer.addEventListener('documentLoaded', () => {
        createSignHereBox({
          name: 'box-1',
          pageNumber: 1,
          x: 100,
          y: 100,
          width: 50,
          height: 20
        })

        setTimeout(() => {
          createSignHereBox({
            name: 'box-3',
            pageNumber: 1,
            x: 100,
            y: 300,
            width: 50,
            height: 20
          })
        }, 5000)
      })
    })

    // if (this.idValue === undefined) { return }
    // this.progressTarget.classList.remove("hidden")
    // this.placeholderTarget.classList.add("hidden")
    // this.canvasTarget.classList.add("hidden")
    // this.controlsTarget.classList.add("hidden")
    // var _self = this
    // const url = "/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + "/pdf"
    // var loadingTask = this.pdfjsLib.getDocument(url)
    // loadingTask.onProgress = (progressData) => {
    //   var percentLoaded = progressData.loaded * 100 / progressData.total
    //   this.barTarget.style.width = percentLoaded + "%"
    // }
    // loadingTask.onFailure = () => {
    //   this.placeholderTarget.classList.remove("hidden")
    //   this.progressTarget.classList.add("hidden")
    //   this.canvasTarget.classList.add("hidden")
    //   this._initTabs()
    // }
    // loadingTask.promise.then(pdfDoc => {
    //   this.progressTarget.classList.add("hidden")
    //   this.canvasTarget.classList.remove("hidden")
    //   this.controlsTarget.classList.remove("hidden")
    //   this.barTarget.style.width = "0%"
    //   _self.pdf = pdfDoc
    //   if (_self.hasPageCountTarget) {
    //     _self.pageCountTarget.textContent = _self.pdf.numPages
    //   }
    //   _self._queueRenderPage(_self.currentPage)
    // }).catch(error => {
    //   this._initTabs()
    // })
  }

  // _renderPage(num) {
  //   var _self = this

  //   this.rendering = true
  //   this.pdf.getPage(num).then(page => {
  //     var viewport = page.getViewport({ scale: _self.scale })
  //     _self.canvasTarget.height = viewport.height
  //     _self.canvasTarget.width  = viewport.width

  //     var renderContext = {
  //       canvasContext: _self.ctx,
  //       viewport: viewport
  //     }
  //     var renderTask = page.render(renderContext)

  //     renderTask.promise.then(() => {
  //       _self.rendering = false
  //       if (_self.pendingPage !== null) {
  //         _self._renderPage(_self.pendingPage)
  //         _self.pendingPage = null
  //       } else if (_self.currentPage == _self.pdf.numPages && !_self.documentRead) {
  //         _self.documentRead = true
  //         fetch("/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + "/mark_as_read")
  //           .then(() => {
  //             const signatureController = this.application.getControllerForElementAndIdentifier(document.querySelector("#signature-controller"), "signature")
  //             signatureController.documentIdValueChanged()
  //           })
  //       }
  //     })
  //   })
  //   if (this.hasPageNumTarget) {
  //     this.pageNumTarget.value = num
  //   }
  // }

  // _queueRenderPage(num) {
  //   if (this.rendering) {
  //     this.pendingPage = num
  //   } else {
  //     this._renderPage(num)
  //   }
  // }
}
