CKEDITOR.disableAutoInline = true
CKEDITOR.plugins.add 'structural', init: (editor) ->

  addButton = (commandName, styles, forms, icon) ->
    editor.ui.addButton commandName,
      label: 'Add ' + commandName
      command: commandName
      toolbar: 'structural'
      icon: icon or 'italic'
    style = new (CKEDITOR.style)(styles)
    editor.attachStyleStateChange style, (state) ->
      !editor.readOnly and editor.getCommand(commandName).setState(state)
      return
    editor.addCommand commandName, new (CKEDITOR.styleCommand)(style, contentForms: forms)
    return

  addButton 'heading', { element: 'h1' }, [ 'h1' ]
  addButton 'subtitle', { element: 'h2' }, [ 'h2' ]
  addButton 'blockquote', { element: 'blockquote' }, [ 'blockquote' ], 'blockquote'
  return



Editor = (element) ->
  element.setAttribute 'contenteditable', 'true'
  CKEDITOR.inline element, {
    extraPlugins: 'structural',
    allowedContent: true
    #extraAllowedContent: '*(headline,title,paragraph,text,list,data),*[id]'
  }

module.exports = Editor