palletes = {}
module.exports = (element, image, x, y) ->
  style = element.getElementsByTagName('style')[0] || document.createElement('style')
  image ||= element.getElementsByTagName('img')[0]
  image.id ||= 'u-' + Math.random()
  pallete = palletes[image.id] ||= Pallete(image)
  style.textContent = pallete(null, x, y).toString('#' + element.id + ' ')
  unless style.parentNode == element
    element.appendChild(style)

module.exports.find = ->
  for image in document.getElementsByTagName('img')
    callback = ->
      while parent = (parent || @).parentNode
        if parent.tagName == 'ARTICLE'
          id = parent.id ||= 'u-' + Math.floor(Math.random() * 10000000)
          break

      parent.setAttribute('color-x', 4)
      parent.setAttribute('color-y', 4)


      module.exports(parent, @,
        parseFloat(parent.getAttribute('color-x')), 
        parseFloat(parent.getAttribute('color-y'))
      )

    if image.complete
      callback.call(image)
    else
      image.onload = callback

exposed = null

module.exports.example = (path, index) ->
  img = new Image()
  img.src = path
  img.onload = ->
    picture = article.getElementsByTagName('picture')[0]
    picture.style.flexBasis = img.width + 'px'
    picture.style.webkitFlexBasis = img.width + 'px'
    picture.style.maxWidth = img.width * 1.25 + 'px'
    if img.width > img.height * 1.1
      picture.classList.add('portrait')
      article.classList.add('forced')
      article.classList.add('vertical')
      article.classList.remove('horizontal')
  article = document.createElement('article')
  article.className = "padded horizontal x-aligned"
  article.classList.add(['inverted', 'uninverted', 'uninverted', 'inverted', 'inverted', 'uninverted'][index % 6])
  article.innerHTML = """
    <div class="box padded vertical textual ">
      <h1>Hello world</h1>
      <p>This is a wonderful day to do the great art. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo.</p>

      <div class="block padded vertical textual">
        <h1>This is a nested <span class="accent">group</span></h1>
        <p>This is a wonderful day to do the great art</p>
      </div>
    </div>
    <picture class="graphical decorated">
      <img src="#{path}" />
    </picture>
  """
  return article
require('./alignment.coffee')

copies = null

Unexpose = (element, callback) ->
  document.body.classList.remove('exposing')
  exposed.style.transform = ''

  copied = copies.slice()
  for copy in copied
    if copy == element
      copy.style.transform = 'scale(1)'
      copy.style.zIndex = '1'
      copy.style.opacity = 0
      copy.style.clip = 'rect(' + 0 + 'px,' + copy.offsetWidth + 'px,' + copy.offsetHeight + 'px,' + 0 + 'px)'
    else if copy
      copy.style.transform = 'scale(0.5)'
      copy.style.zIndex = ''
      copy.style.opacity = 0
  xposed = exposed
  callback?(xposed)
  setTimeout ->
    xposed.style.zIndex = ''
    for copy in copied
      copy?.parentNode?.removeChild(copy)
  , 800
  copies = exposed = null




order = [2,1,0,2,1,0,2,1,0]
Expose = (element, callback) ->
  if copies
    Unexpose()

  document.body.classList.add('exposing')
  exposed = element

  copies = []
  if rect = Expose.getRectangle(element)
    console.log(rect, rect.toString())
    element.style.clip = rect.toString()
  for i in [0...9]
    copy = element.cloneNode(true)
    copy.setAttribute('id', 'copy' + element.id + '-' + i)
    if callback?(copy, i) == false
      continue
    copy.classList.add('copy')
    copy.style.position = 'absolute'
    copy.style.width = element.offsetWidth + 'px'
    copy.style.height = element.offsetHeight + 'px'
    copy.style.top = element.offsetTop + 'px'
    copy.style.left = element.offsetLeft + 'px'
    copy.style.zIndex = 3 + (8 - order[i])
    copy.style.opacity = 0
    copy.style.transform = 'scale(0.75)'
    copy.style.transition = 'clip 0.3s, opacity 0.4s ' + parseFloat((0.05 * order[i]).toFixed(3)) + 's, transform 0.3s ease-in ' + parseFloat((0.04 * order[i]).toFixed(3)) + 's'
    copies[i] = copy
    console.log(i, order[i])
  
  totalLeft = 0
  while parent || (parent = element)
    totalLeft += parent.offsetLeft || 0
    break unless parent = parent.offsetParent

  shift = 'translateX(' + (window.innerWidth / 2 - totalLeft - element.offsetWidth / 2) + 'px) '
  
  for copy in copies
    if copy
      element.parentNode.insertBefore(copy, element.nextSibling)

  requestAnimationFrame ->
    requestAnimationFrame ->
      for copy, i in copies
        continue unless copy
        copy.style.opacity = 1
        copy.style.transform = 'scale(0.5)'
        p = 3
        switch i
          when 0
            copy.style.transform = shift + 'translateY('+ (rect.bottom + rect.top - p) / 2 + 'px) translateX('+ (rect.right + rect.left - p) / 2 + 'px) ' +
            'scale(0.5) translateX(-100%) translateY(-100%)'
          when 1
            copy.style.transform = shift + 'translateY('+ (rect.bottom + rect.top - p) / 2 + 'px)  scale(0.5) translateY(-100%)'
          when 2
            copy.style.transform = shift + 'translateY('+ (rect.bottom + rect.top - p) / 2 + 'px) translateX('+ (- rect.left - rect.right + p) / 2 + 'px) ' +
            'scale(0.5) translateX(100%) translateY(-100%)'
          when 3
            copy.style.transform = shift + 'translateX('+ (rect.right + rect.left - p) / 2 + 'px) ' +
            'scale(0.5) translateX(-100%)'
          when 4
            copy.style.transform = shift + 'translateX(0px) ' +
            'scale(0.5)'
          when 5
            copy.style.transform = shift + 'translateX('+ (- rect.left - rect.right + p) / 2 + 'px) ' +
            'scale(0.5) translateX(100%)'
          when 6
            copy.style.transform = shift + 'translateY('+ (-rect.bottom - rect.top + p)/ 2 + 'px) ' +
            'translateX('+ (rect.right + rect.left - p) / 2 + 'px) scale(0.5) translateX(-100%) translateY(100%)'
          when 7
            copy.style.transform = shift + 'translateY('+ (-rect.bottom - rect.top + p)/ 2 + 'px) ' +
            'scale(0.5) translateY(100%)'
          when 8
            copy.style.transform = shift + 'translateY('+ (-rect.bottom - rect.top + p)/ 2 + 'px) ' +
            'translateX('+ (- rect.left - rect.right + p) / 2 + 'px) scale(0.5) translateX(100%) translateY(100%)'

getChildren = (element) ->
  if element.classList.contains('inverted')
    list = Array.prototype.reverse.call(Array.prototype.slice.call(element.children))
  else
    list = Array.prototype.slice.call(element.children)

  return list.filter (el) -> el.tagName != 'STYLE'

Expose.getRectangle = (element) ->
  list = getChildren(element)
  if element.classList.contains('vertical') || element.classList.contains('actually-vertical')
    offsetWidth = 0
    offsetLeft = 0
    for child in list
      if offsetWidth < child.offsetWidth 
        offsetWidth = child.offsetWidth
        offsetLeft = child.offsetLeft
    offsetTop = list[0].offsetTop
    if list[0].tagName == 'PICTURE'
      offsetTop += list[0].offsetHeight - 200
    offsetHeight = list[list.length - 1].offsetTop + list[list.length - 1].offsetHeight - offsetTop
    if list[1].tagName == 'PICTURE'
      offsetHeight -= list[1].offsetHeight - 200
  else
    offsetHeight = 0
    offsetTop = 0
    for child in list
      if offsetHeight < child.offsetHeight 
        offsetHeight = child.offsetHeight
        offsetTop = child.offsetTop
    offsetLeft = list[0].offsetLeft
    offsetWidth = list[list.length - 1].offsetLeft + list[list.length - 1].offsetWidth - offsetLeft
  return {
    top: offsetTop
    left: offsetLeft
    right: element.offsetWidth - offsetWidth - offsetLeft
    bottom: element.offsetHeight - offsetHeight - offsetTop
    height: offsetHeight
    width: offsetWidth
    toString: ->
      'rect(' + @top + 'px,' + (@left + @width) + 'px,' + (@top + @height) + 'px,' + @left + 'px)'
  }


        
  #else
  #  for element in children


shifts = [
  [-1,-1]
  [0,-1]
  [1, -1]
  [-1,0]
  [0,0]
  [1, 0]
  [-1,1]
  [0, 1]
  [1, 1]
]

document.addEventListener('click', (e) ->
  parent = e.target
  while parent
    if parent.tagName == 'ARTICLE'
      e.preventDefault()
      if parent.classList.contains('copy')
        Unexpose(parent, (element) ->
          element.setAttribute('color-x', parent.getAttribute('color-x'))
          element.setAttribute('color-y', parent.getAttribute('color-y'))
          module.exports(element, null,
            parseFloat(element.getAttribute('color-x')), 
            parseFloat(element.getAttribute('color-y'))
          )
        )

      else if parent == exposed
        Unexpose()
      else
        Expose(parent, (element, i) ->
          [x, y] = shifts[i]
          element.setAttribute('color-x', parseFloat(parent.getAttribute('color-x')) + x)
          element.setAttribute('color-y', parseFloat(parent.getAttribute('color-y')) + y)
          try
            module.exports(element, null,
              parseFloat(element.getAttribute('color-x')), 
              parseFloat(element.getAttribute('color-y'))
            )
          catch e
            return false
        )
      break
    unless (parent = parent.parentNode).nodeType == 1
      break 
)

layout = document.getElementById('layout')
for i in [30 .. 36]
  article = module.exports.example("./images/#{i}.jpg", i - 30)
  layout.appendChild(article)

module.exports.find()