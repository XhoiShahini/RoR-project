import { Controller } from "stimulus"
import consumer from "channels/consumer"
import PDFJSExpress from '@pdftron/pdfjs-express'

const disabledElements = [
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

export default class extends Controller {
  static targets = ['progress', 'viewer', 'title', 'generatePdf', 'controls']
  static values = { id: String, meetingId: String, isParticipant: Boolean }

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

    this.titleTarget.innerText = ''
    this.generatePdfTarget.classList.add('hidden')

    this.viewerTarget.innerHTML = ''
    this.viewerTarget.appendChild(newViewer)
  }

  async _loadDocument() {
    try {
      return await fetch("/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + '.json')
        .then(r => r.json())
    } catch (error) {
      console.error('_loadDocument', error)
      return {}
    }
  }

  async _initPdf() {
    this._createNewViewerEl()
    this.progressTarget.classList.remove('hidden')
    this.controlsTarget.classList.add('hidden')

    const url = "/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + "/pdf"
    console.debug('Load', url)

    const documentData = await this._loadDocument()
    console.debug('documentData', documentData)

    PDFJSExpress({
      path: '/pdftron',
      initialDoc: url,
      disabledElements
    }, document.getElementById('viewer')).then(instance => {

      this.progressTarget.classList.add('hidden')
      this.titleTarget.innerText = documentData.title || ''
      this.controlsTarget.classList.remove('hidden')
      document.getElementById('viewer').classList.remove('hidden')

      const {
        docViewer,
        annotManager: annotationManager,
        Core: {
          Annotations
        }
      } = instance

      annotationManager.addEventListener('annotationChanged', (annotations, action, info) => {
        // console.log('annotationChanged', annotations, annotations[0].id, action, info)
        const allSignatureWidgetAnnots = annotationManager.getAnnotationsList()
          .filter(annot => annot instanceof Annotations.SignatureWidgetAnnotation)

        // See https://www.pdftron.com/documentation/web/guides/interacting-with-signature-field/#annotation-associated-with-signature-widget
        const check = allSignatureWidgetAnnots.every(sigAnnot => Boolean(sigAnnot.annot))
        if (check) {
          this.generatePdfTarget.classList.remove('hidden')
          this.generatePdfTarget.onclick = () => {
            console.log('Clicked!!')
            onSave()
          }
        } else {
          const firstNotSigned = allSignatureWidgetAnnots.find(sigAnnot => !Boolean(sigAnnot.annot))
          if (firstNotSigned) {
            annotationManager.jumpToAnnotation(firstNotSigned)
          }

          this.generatePdfTarget.classList.add('hidden')
        }
      })

      const onSave = async () => {
        const xfdf = await annotationManager.exportAnnotations({ links: false, widgets: false })
        // Send Annotations
        try {
          const url = "/meetings/" + this.meetingIdValue + "/documents/" + this.idValue + "/xfdf"

          console.log('Send Data to', url)
          const csrfToken = document.querySelector("[name='csrf-token']").content
          const response = await fetch(url, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': csrfToken,
            },
            body: JSON.stringify({ xfdf })
          }).then(r => r.json())

          console.error('PDF Saved!', response)
        } catch (error) {
          console.error('Upload Annotations error:', error)
        }
      }

      const createSignHereBox = ({ pageNumber, x, y, width, height, name }) => {
        console.log('createSignHereBox', pageNumber, x, y, width, height, name)

        const field = new Annotations.Forms.Field(name, { type: 'Sig' })
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

      docViewer.addEventListener('pageNumberUpdated', async (pageNumber) => {
        const pageCount = docViewer.getPageCount()
        console.log('pageNumber', pageNumber, pageCount)

        if (pageNumber === pageCount) {
          try {
            await fetch(`/meetings/${this.meetingIdValue}/documents/${this.idValue}/mark_as_read`)
            const signatureController = this.application.getControllerForElementAndIdentifier(document.querySelector("#signature-controller"), "signature")
            if (signatureController) {
              signatureController.documentIdValueChanged()
            }

            // Remove listener since we are done with it
            docViewer.removeEventListener('pageNumberUpdated')

          } catch (error) {
            console.error('Mark As Read Error', error)
          }
        }
      })

      docViewer.addEventListener('documentLoaded', () => {

        const disableSign = () => {
          docViewer.removeEventListener('pageNumberUpdated')
          docViewer.removeEventListener('annotationChanged')
        }

        if (!this.isParticipantValue) {
          disableSign()
          return console.debug('Not a participant')
        }
        if (Boolean(documentData?.xfdf_merged)) {
          disableSign()
          return console.debug('PDF already merged!')
        }
        const { version, fields } = documentData.signature_fields || {}
        console.log('LOADED', version, fields)
        switch (version) {
          case '1': {
            Object.keys(fields).sort((a, b) => {
              const fieldA = fields[a]
              const fieldB = fields[b]
              if (fieldA.pageNumber < fieldB.pageNumber) {
                return -1
              }
              if (fieldA.pageNumber > fieldB.pageNumber) {
                return 1
              }
              return 0
            }).forEach(fieldId => {
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
