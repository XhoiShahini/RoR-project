import { Controller } from "stimulus"
import consumer from "channels/consumer"
import PDFJSExpress from '@pdftron/pdfjs-express'

export default class extends Controller {
  static targets = ['progress', 'viewer']
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

  _createNewViewerEl() {
    const newViewer = document.createElement('div')
    newViewer.id = 'viewer'
    newViewer.classList.add('h-full', 'hidden')

    this.viewerTarget.innerHTML = ''
    this.viewerTarget.appendChild(newViewer)
  }

  async _loadSignatureFields() {
    try {
      return await fetch("/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + '.json')
        .then(r => r.json())
        .then(r => r.signature_fields || {})
    } catch (error) {
      console.error('_loadSignatureFields', error)
      return {}
    }
  }

  async _initPdf() {
    this._createNewViewerEl()
    this.progressTarget.classList.remove('hidden')

    const url = "/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + "/pdf"
    console.debug('Load', url)

    const sigFields = await this._loadSignatureFields()
    console.debug('sigFields', sigFields)

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

      this.progressTarget.classList.add('hidden')
      document.getElementById('viewer').classList.remove('hidden')

      const {
        docViewer,
        annotManager: annotationManager,
        Core: {
          Annotations
        }
      } = instance

      const createSignHereBox = ({ pageNumber, x, y, width, height, name }) => {
        console.log('createSignHereBox', pageNumber, x, y, width, height, name)
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
        widgetAnnot.PageNumber = pageNumber
        widgetAnnot.X = x
        widgetAnnot.Y = y
        widgetAnnot.Width = width
        widgetAnnot.Height = height
        widgetAnnot.NoResize = true
        widgetAnnot.NoRotate = true

        // add the form field and widget annotation
        annotationManager.getFieldManager().addField(field)
        annotationManager.addAnnotation(widgetAnnot)
        annotationManager.drawAnnotationsFromList([widgetAnnot])
      }

      // docViewer.addEventListener('pageComplete', (pageNumber, canvas) => {
      //   console.warn('pageComplete??', pageNumber)
      // })

      docViewer.addEventListener('documentLoaded', () => {

        const { version, fields } = sigFields
        console.log('LOADED', version, fields)
        switch (version) {
          case '1': {
            Object.keys(fields).forEach(fieldId => {
              const field = fields[fieldId]
              createSignHereBox({
                name: fieldId,
                pageNumber: field.pageNumber,
                x: Math.floor(field.x),
                y: Math.floor(field.y),
                width: 80,
                height: 30
              })
            })
            break
          }
        }
      })
    })
  }
}
