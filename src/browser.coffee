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
  article.className = "padded horizontal x-aligned has-connector"
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
  exposed.style.opacity = ''
  exposed.classList.remove('exposed')
  document.removeEventListener('mousemove', listener)

  copied = copies.slice()
  for copy in copied
    continue unless copy
    copy.parentNode.classList.remove('open')
  xposed = exposed
  callback?(xposed, element)
  setTimeout ->
    copy.parentNode.parentNode.removeChild(copy.parentNode)
    xposed.style.zIndex = ''
  , 600
  copies = exposed = null


Perspective = (element, e, rect) ->
  unless placeholder = element.querySelectorAll('span.placeholder')
    placeholder = document.createElement('span')
    placeholder.className = 'placeholder'
    placeholder.style.position = 'absolute'
    placeholder.style.top = '0'
    placeholder.style.left = '0'
    totalWidth = (rect.width) * 0.65 * 3
    totalHeight = (rect.height) * 0.65 * 3
    placeholder.style.width = totalWidth + 'px'
    placeholder.style.height = totalHeight + 'px'
    element.appendChild(placeholder)

  ease = (t) ->
    return t * t
  x = Math.min(element.offsetWidth, Math.max(0, e.pageX - element.offsetLeft))
  negateX = (x / element.offsetWidth - 0.5) < 0
  X = Math.max(0, Math.min(1, ease Math.abs(x / element.offsetWidth - 0.5)))
  if negateX
    X = - X

  y = Math.min(element.offsetHeight, ease Math.max(0, e.pageY - element.offsetTop))
  negateY = (y / element.offsetHeight - 0.5) < 0
  Y = Math.max(0, Math.min(1, ease Math.abs(y / element.offsetHeight - 0.5)))
  if negateY
    Y = - Y


  x = '50%'
  y = '50%'
  totalWidth = (rect.width) * 0.65 * 3
  totalHeight = (rect.height) * 0.65 * 3
  if (diffX = (totalWidth - element.offsetWidth)) > 0
    x = X * -diffX

  if (diffY = (totalHeight - element.offsetHeight)) > 0
    y = Y * -diffY

  console.error([X,Y],[x,y],diffY, diffX, 666)
  
  element.scrollLeft = totalWidth / 2 - x
  element.scrollTop = totalHeight / 2 - y
 

order = [0,0,0,1,1,1,2,2,2]

listener = null
shift = ''
Expose = (element, callback, e) ->
  if copies
    Unexpose()

  element.classList.add('exposed')
  exposed = element

  copies = []
  if rect = Expose.getRectangle(element)
    element.style.transform = 'scale(0.65)'
    element.style.opacity = '0'
  totalWidth = (rect.width ) * 3
  totalHeight = (rect.height) * 3

  centerY = element.offsetHeight / 2
  cY = rect.top + rect.height / 2
  shift = 'translateY(' + (centerY - cY) + 'px)' + 'translateX(' + totalWidth / 2 + 'px) translateY(' + totalHeight / 2 + 'px)'
  

  element.style.clip = rect.toString()
  for i in [0...9]
    copy = element.cloneNode(true)
    copy.getElementsByTagName('h1')[0]?.innerHTML

    if i == 4
      copy.style.clip = rect.toString(20)
      mid = copy
    else
      copy.onmouseover = ->
        @style.clip = rect.toString(20)
      copy.onmouseout = ->
        @style.clip = rect.toString(0)


    copy.setAttribute('id', 'copy-' + element.id + '-' + i)
    if callback?(copy, i) == false
      continue
    copy.classList.add('copy')
    copy.style.position = 'absolute'
    copy.style.width = element.offsetWidth + 'px'
    copy.style.height = element.offsetHeight + 'px'
    copy.style.top = 0 + 'px'
    copy.style.left = 0 + 'px'
    copy.style.zIndex = 3 + (8 - order[i])
    if i == 4
      copy.style.opacity = 0
    copy.style.transition = 'clip 0.7s, opacity 0.35s ' + parseFloat((0.1 * Math.floor(Math.random() * 3)).toFixed(3)) + 's, transform 0.35s  '
    copies[i] = copy
    scale = 0.65
    p = 4
    #copy.style.transformOrigin = 'center ' + (rect.bottom / rect.top) / 2 * 100 + '%'
    switch i
      when 0
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY('+ (rect.bottom + rect.top - p) + 'px) translateX('+ (rect.right + rect.left - p) + 'px) ' +
        'translateX(-120%) translateY(-120%)'
      when 1
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY('+ (rect.bottom + rect.top - p) + 'px)  translateY(-120%)'
      when 2
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY('+ (rect.bottom + rect.top - p) + 'px) translateX('+ (- rect.left - rect.right + p) + 'px) ' +
        'translateX(120%) translateY(-120%)'
      when 3
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateX('+ (rect.right + rect.left - p) + 'px) ' +
        'translateX(-120%)'
      when 4
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateX(0px) '
      when 5
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateX('+ (- rect.left - rect.right + p) + 'px) ' +
        'translateX(120%)'
      when 6
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY('+ (-rect.bottom - rect.top + p) + 'px) ' +
        'translateX('+ (rect.right + rect.left - p) + 'px) translateX(-120%) translateY(120%)'
      when 7
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY('+ (-rect.bottom - rect.top + p) + 'px) ' +
        'translateY(120%)'
      when 8
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY('+ (-rect.bottom - rect.top + p) + 'px) ' +
        'translateX('+ (- rect.left - rect.right + p) + 'px) translateX(120%) translateY(120%)'

    copy.setAttribute('original-transform', copy.style.transform)
  

  parent = document.createElement('div')
  chosen = null

  listener = (e) ->
    Perspective(parent, e, rect)
    if (hover = Article(e.target))
      if (chosen && hover != chosen)
        chosen.classList.remove('selected')
      chosen = hover
      chosen.classList.add('selected')
  
  document.addEventListener('mousemove', listener)
  parent.classList.add('copies')
  parent.style.overflow = 'hidden'
  parent.style.perspective = '1px'
  parent.style.position = 'absolute'
  parent.style.left = element.offsetLeft + 'px'
  parent.style.top = element.offsetTop + 'px'
  parent.style.width = element.offsetWidth + 'px'
  parent.style.height = element.offsetHeight + 'px'
  parent.style.overflow = 'hidden'
  for copy in copies
    if copy
      parent.appendChild(copy)
  element.parentNode.insertBefore(parent, element.nextSibling)

  requestAnimationFrame ->
    document.body.classList.add('exposing')
    parent.classList.add('open')
    Perspective(parent, e, rect)
    requestAnimationFrame ->
      for copy, i in copies
        continue unless copy
        copy.style.opacity = 1
        p = 3
        scale = 0.65
        resize = 'scale(0.65)'
        midScale = 1 - 22 / rect.width
        switch i
          when 0
            copy.style.transform = resize + shift + 'translateY('+ (rect.bottom + rect.top - p) + 'px) translateX('+ (rect.right + rect.left - p) + 'px) ' +
            'translateX(-100%) translateY(-100%)'
          when 1
            copy.style.transform = resize + shift + 'translateY('+ (rect.bottom + rect.top - p) + 'px) translateY(-100%)'
          when 2
            copy.style.transform = resize + shift + 'translateY('+ (rect.bottom + rect.top - p) + 'px) translateX('+ (- rect.left - rect.right + p) + 'px) ' +
            'translateX(100%) translateY(-100%)'
          when 3
            copy.style.transform = resize + shift + 'translateX('+ (rect.right + rect.left - p) + 'px) ' +
            'translateX(-100%)'
          when 4
            copy.style.transform = resize + shift
          when 5
            copy.style.transform = resize + shift + 'translateX('+ (- rect.left - rect.right + p) + 'px) ' +
            'translateX(100%)'
          when 6
            copy.style.transform = resize + shift + 'translateY('+ (-rect.bottom - rect.top + p) + 'px) ' +
            'translateX('+ (rect.right + rect.left - p) + 'px) translateX(-100%) translateY(100%)'
          when 7
            copy.style.transform = resize + shift + 'translateY('+ (-rect.bottom - rect.top + p) + 'px) ' +
            'translateY(100%)'
          when 8
            copy.style.transform = resize + shift + 'translateY('+ (-rect.bottom - rect.top + p) + 'px) ' +
            'translateX('+ (- rect.left - rect.right + p) + 'px) translateX(100%) translateY(100%)'

getChildren = (element) ->
  if element.classList.contains('inverted')
    list = Array.prototype.reverse.call(Array.prototype.slice.call(element.children))
  else
    list = Array.prototype.slice.call(element.children)

  return list.filter (el) -> el.tagName != 'STYLE'

Expose.getRectangle = (element) ->
  list = getChildren(element)


  imageHeight = 150

  if element.classList.contains('vertical') || element.classList.contains('actually-vertical')
    offsetWidth = 0
    offsetLeft = 0
    for child in list
      if offsetWidth < child.offsetWidth 
        offsetWidth = child.offsetWidth
        offsetLeft = child.offsetLeft
    offsetTop = list[0].offsetTop
    offsetHeight = list[list.length - 1].offsetTop + list[list.length - 1].offsetHeight - offsetTop
    if list[0].tagName == 'PICTURE'
      space = element.offsetHeight - offsetHeight + list[0].offsetHeight
      offsetTop += list[0].offsetHeight - space / 3
      offsetHeight = list[list.length - 1].offsetTop + list[list.length - 1].offsetHeight - offsetTop
    if list[1].tagName == 'PICTURE'
      space = element.offsetHeight - offsetHeight + list[1].offsetHeight
      offsetHeight -= list[1].offsetHeight - space / 3
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
    toString: (offset = 0) ->
      'rect(' + (@top + offset) + 'px,' + (@left + @width - offset) + 'px,' + (@top + @height - offset) + 'px,' + (@left + offset) + 'px)'
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

Article = (parent) ->
  while parent?.nodeType == 1
    if parent.tagName == 'ARTICLE'
      return parent
    parent = parent.parentNode
  return


document.addEventListener('click', (e) ->
  parent = e.target
  while parent
    if parent.tagName == 'ARTICLE'
      e.preventDefault()
      if parent.classList.contains('copy')
        if exposed
          parent
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
        , e)
      break
    unless (parent = parent.parentNode).nodeType == 1
      break 
)

layout = document.getElementById('layout')
for i in [30 .. 36]
  article = module.exports.example("./images/#{i}.jpg", i - 30)
  layout.appendChild(article)

module.exports.find()