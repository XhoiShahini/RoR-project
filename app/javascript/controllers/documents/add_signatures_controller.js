import { Controller } from "stimulus"
import PDFJSExpress from '@pdftron/pdfjs-express'

const CURRENT_VERSION = '1'
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
  static values = {
    id: String,
    url: String,
    meetingId: String,
    meetingUrl: String,
    updateUrl: String,
    fields: Object,
  }
  _pdfInstanceRef = null

  save() {
    const fields = {}
    this._pdfInstanceRef.annotManager.getAnnotationsList().forEach((annot) => {
      if (Boolean(annot.__agreeId)) {
        fields[annot.Id] = {
          x: annot.X,
          y: annot.Y,
          pageNumber: annot.PageNumber,
          memberId: annot.__memberId,
          color: annot.__color
        }
      }
    })
    console.log('Save???', fields)

    const csrfToken = document.querySelector("[name='csrf-token']").content
    fetch(this.updateUrlValue, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({
        document: {
          signature_fields: {
            version: CURRENT_VERSION,
            fields: fields
          }
        }
      })
    })
      .then(response => response.json())
      .then(data => {
        console.debug('Saved!', data, this.meetingUrlValue)
        window.location.href = this.meetingUrlValue
      })
  }

  connect() {
    console.log('Connect', this.fieldsValue, this.updateUrlValue)

    PDFJSExpress({
      path: '/pdftron',
      licenseKey: 'GoWk97mVlr2I3EfL1kVU',
      initialDoc: this.urlValue,
      disabledElements
    }, document.getElementById('viewer')).then(instance => {
      this._pdfInstanceRef = instance
      console.log('Connect THIS', this)

      const { docViewer } = instance

      const getMouseLocation = (event) => {
        const scrollElement = docViewer.getScrollViewElement()
        const scrollLeft = scrollElement.scrollLeft || 0
        const scrollTop = scrollElement.scrollTop || 0

        return {
          x: event.pageX + scrollLeft,
          y: event.pageY + scrollTop
        }
      }

      // annotationManager.addEventListener('annotationChanged', (annotations, action, info) => {
      //   console.log('annotationChanged', annotations, action, info)
      // })

      docViewer.addEventListener('dblClick', (event) => {
        var selected = document.querySelector('input[name="mm-select"]:checked')
        console.log(selected.value, selected.dataset.color)
        const windowCoordinates = getMouseLocation(event)
        const pageNumber = docViewer.getCurrentPage()
        const displayMode = docViewer.getDisplayModeManager().getDisplayMode()
        const coords = displayMode.windowToPage(windowCoordinates, pageNumber)
        this.createPlaceholderBox({
          pageNumber,
          x: coords.x,
          y: coords.y,
          memberId: selected.value,
          color: selected.dataset.color,
        })
      })


      docViewer.addEventListener('documentLoaded', () => {
        this._applyInitialPlaceholderBoxes()
      })
    })
  }

  createPlaceholderBox(options){
    const { pageNumber, x, y, width = 100, height = 30 } = options
    if (typeof pageNumber !== 'number' || typeof x !== 'number' || typeof y !== 'number') {
      return console.warn('Invalid args for placeholderBox', options)
    }

    const {
      annotManager: annotationManager,
      Core: {
        Annotations
      }
    } = this._pdfInstanceRef

    const annot = new Annotations.RectangleAnnotation()
    annot.PageNumber = pageNumber
    annot.X = x
    annot.Y = y
    annot.Width = width
    annot.Height = height
    annot.NoResize = true
    annot.NoRotate = true

    const strokeAlpha = 1;
    const fillAlpha = 0.3;

    console.log("COLOR IS", options.color);
    switch(options.color) {
      case '#f00':
        console.log('is red')
        annot.Color = new Annotations.Color(255, 0, 0, strokeAlpha);
        annot.FillColor = new Annotations.Color(255, 0, 0, fillAlpha);
        break;
      case '#0f0':
        annot.Color = new Annotations.Color(0, 255, 0, strokeAlpha);
        annot.FillColor = new Annotations.Color(0, 255, 0, fillAlpha);
        break;
      case '#00f':
        annot.Color = new Annotations.Color(0, 0, 255, strokeAlpha);
        annot.FillColor = new Annotations.Color(0, 0, 255, fillAlpha);
        break;
      default:
        annot.Color = new Annotations.Color(0, 0, 0, strokeAlpha); 
        annot.FillColor = new Annotations.Color(0, 0, 0, fillAlpha); 
        break;
    }
    annot.__agreeId = '_' + Date.now().toString()
    annot.__memberId = options.memberId
    annot.__color = options.color

    console.log('annotation', annot)

    annotationManager.addAnnotation(annot)
    // need to draw the annotation otherwise it won't show up until the page is refreshed
    annotationManager.redrawAnnotation(annot)
  }

  _applyInitialPlaceholderBoxes() {
    const { version, fields } = this.fieldsValue

    switch (version) {
      case CURRENT_VERSION: {
        const ids = Object.keys(fields)
        if (!ids.length) {
          return console.debug('No Placeholders To Render')
        }
        ids.forEach((id) => this.createPlaceholderBox(fields[id]))
        break
      }
      default:
        console.warn('Unknown version', this.fieldsValue)
    }

  }
}
