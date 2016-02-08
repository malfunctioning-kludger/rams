Page = (element) ->
  if element.nodeType == 9
    element = element.body

  for article in element.getElementsByTagName('article')
    Article(article)

Article = (element) ->
  item = {
    metadata: {
      author: {}
      publisher: {}
    }
  }
  item.blocks = Array.prototype.map.call element.children, (child) ->
    switch child.tagName
      when 'H1'
        {title: child.innerHTML}
      when 'H2'
        {subtitle: child.innerHTML}
      when 'P'
        {text: child.innerHTML}
      when 'UL', 'OL'
        {list: child.innerHTML}
      when 'IMG'
        {cover: {
          src: child.src
          height: child.getAttribute('height') ? child.naturalHeight
          width: child.getAttribute('width') ? child.naturalWidth
        }}
  return item

module.exports = Page