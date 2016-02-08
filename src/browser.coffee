module.exports = ->
  for image in document.getElementsByTagName('img')
    callback = ->
      while parent = (parent || @).parentNode
        if parent.tagName == 'ARTICLE'
          id = parent.id ||= 'u-' + Math.floor(Math.random() * 10000000)
          break

      style = document.createElement('style')
      style.textContent = Pallete(@)('DV+LV').toString('#' + id + ' ')
      @parentNode.appendChild(style)

    if image.complete
      callback.call(image)
    else
      image.onload = callback

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

layout = document.getElementById('layout')
for i in [30 .. 36]
  article = module.exports.example("./images/#{i}.jpg", i - 30)
  layout.appendChild(article)
module.exports()