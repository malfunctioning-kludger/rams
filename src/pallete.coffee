require('./vibrant.coffee')


Samples = ->
  for i in [16 ... 17]
    module.exports.output('./images/' + i + '.jpg')

global.Pallete = module.exports = (img) ->
  vibrance = new Vibrant(img, 120, 1)
  swatches = vibrance.swatches()
  matrix = Matrix(swatches)
  generator = (name, I, J) ->
    for row, i in Space
      for cell, j in row
        if j < 7
          if name == cell || (i == I && j == J)
            return Schemes[cell](swatches, matrix, (I ? i) / 6, (J ? j) / 6)
    return
  generator.debug = ->
    module.exports.debug(swatches, matrix)

  return generator

module.exports.samples = Samples

module.exports.output = (path) ->
  img = document.createElement('img');
  img.setAttribute('src', path)
  img.onload = ->
    Generator = module.exports(img)

    hr = document.createElement('hr')
    hr.style.clear = 'both'
    document.body.appendChild(hr)


    scheme = Schemes.dark

    list = Generator.debug()


    img.style.maxWidth = '400px'
    img.style.float = 'left'
    img.style.maxHeight = '250px'
    document.body.appendChild(img)
    document.body.appendChild(list)

    hr = document.createElement('hr')
    hr.style.clear = 'both'
    hr.style.visibility = 'hidden'
    document.body.appendChild(hr)


    for row, index in Space
      for cell, j in row
        if j < 7
          document.body.appendChild(module.exports.example(Generator(cell), j + 1))

    hr = document.createElement('hr')
    hr.style.clear = 'both'
    hr.style.visibility = 'hidden'
    document.body.appendChild(hr)


Adjust = (colors) ->
  pallete = {}
  for property, value of colors
    if value
      hsl = value.getHsl()
      if property.indexOf('Dark') > -1

        if value.getPopulation() < 3000
          if (diff = (hsl[2] - 0.15)) > 0
            pallete[property] = new Swatch Vibrant.hslToRgb(hsl[0], hsl[1], hsl[2] * (1 - diff * 2)), value.getPopulation()

      else if property.indexOf('Light') > -1
        if value.getPopulation() < 6000
          if (diff = (0.85 - hsl[2])) > 0
            pallete[property] = new Swatch Vibrant.hslToRgb(hsl[0], hsl[1], hsl[2] * (1 + diff * 2)), value.getPopulation()

      if value.getPopulation() < 1000
        if property.indexOf('Vibrant') > -1
          if property.indexOf('Light') > -1 || property.indexOf('Dark') > -1
            if (diff = (0.65 - hsl[1])) > 0
              pallete[property] = new Swatch Vibrant.hslToRgb(hsl[0], hsl[1] * (1 + diff), hsl[2]), value.getPopulation()
          else
            if (diff = (0.85 - hsl[1])) > 0
              pallete[property] = new Swatch Vibrant.hslToRgb(hsl[0], hsl[1] * (1 + diff * 2), hsl[2]), value.getPopulation()
          
      pallete[property] ?= value

  return pallete


Contrast = (c1, c2) ->
  if (c1[2] > c2[2])
    return (c1[2] + 0.05) / (c2[2] + 0.05)
  return (c2[2] + 0.05) / (c1[2] + 0.05)


YIQ = (color) ->
  (color.rgb[0] * 299 + color.rgb[1] * 587 + color.rgb[2] * 114) / 1000

Row = (name, bg, text) ->
  contrast = Contrast(bg.getHsl(), text.getHsl())

  # Contrast is not too far off
  t = text.getHsl()
  b = bg.getHsl()
  yiq = YIQ(bg)
  if contrast < 4 || (yiq < 100 && contrast < 8)
    if contrast > 2.6 && yiq > 100
      if t[2] > b[2]
        adjusted = new Swatch Vibrant.hslToRgb(t[0], t[1], (b[2] + 0.05) * 7)
      else 
        adjusted = new Swatch Vibrant.hslToRgb(t[0], t[1], (b[2] + 0.05) / 7)
    else
      if yiq < 150
        adjusted = new Swatch [255,255,255], 0
      else
        adjusted = new Swatch [0,0,0], 0



  return [text, contrast, adjusted]

Matrix = (swatches) ->
  matrix = {}
  for p1, bgAll of swatches
    for bg in bgAll
      key = String(bg)
      for p2, textAll of swatches
        for text in textAll
          if text# && Contrast(bg.getHsl(), swatches[p2].getHsl()) > 4
            (matrix[key] ||= []).push(Row(p2, bg, text))

      matrix[key] = matrix[key].sort (a, b) ->
        b[1] - a[1]
  return matrix

Find = (swatches, order, luma, saturation, result, callback, fallback) ->
  collection = []

  for label in order
    if colors = swatches[label]
      for color in colors
        used = false
        for property, other of result
          if other == color
            used = true
            break
        unless used
          collection.push color

      continue unless collection.length

      if callback
        if callback.length == 1
          collection = collection.filter(callback)
          if collection.length
            return collection 
        else
          collection = collection.sort(callback)
      else
        if luma?

          if (saturation % 0.5) > (luma % 0.5)

            collection = collection.sort (a, b) ->
              return (b.getHsl()[2] - a.getHsl()[2])# * luma + (a.getHsl()[1] - b.getHsl()[1]) * saturation


          else
            collection = collection.sort (a, b) ->
              return (b.getHsl()[1] - a.getHsl()[1])

          collection = [collection[Math.floor(Math.max(0, ((saturation % 0.5) - 0.00001) * 2) * Math.min(2, collection.length))]]




        break

  if callback
    if !collection.length && fallback
      return Find(swatches, fallback, result, callback)
    return collection[0]
  else
    return collection[Math.floor(Math.random() * collection.length)]


Pallete = (swatches, matrix, luma, saturation, preset) ->
  result = Object.create(preset)

  for property, values of preset
    continue unless values?.push
    if values[0].push
      [fallback, order] = values
    else
      fallback = null
      order = values

    if property == 'foreground'
      colors = Find swatches, order, luma, saturation, result, (a) ->
        Contrast(result.background.getHsl(), a.getHsl()) > 1.2
      , fallback

    else if property == 'accent'
      colors = Find swatches, order, luma, saturation, result, (a, b) ->
        (Contrast(result.background.getHsl(), b.getHsl()) + Contrast(result.foreground.getHsl(), b.getHsl())) / 2 - 
        (Contrast(result.background.getHsl(), a.getHsl()) + Contrast(result.foreground.getHsl(), a.getHsl())) / 2
      
    else if property == 'background'
      colors = Find swatches, order, luma, saturation, result

    if colors
      if colors.length
        color = colors[0]
      else
        color = colors

      result[property] = color
      result[property + 'AAA'] = matrix[color][0][2] || matrix[color][0][0]
      result[property + 'AA']  = matrix[color][1][2] || matrix[color][1][0]
  return result

Space = """
  DM+DM DM+M  DV+M  DV+LM DV+V  DV+DV DV+DV
  DM+M  M+DM  DV+M  DV+M  DV+V  DV+LV DV+V
  DM+M  M+DM  M+DV  M+DV  DV+DV V+DV  V+DV
  M+M   M+M   M+V   M+V   V+M   V+V   V+V
  M+LM  M+LM  M+LV  M+LV  V+LV  V+LV  V+LV 
  LM+M  M+LM  LV+M  LV+M  LV+V  LV+LV LV+V 
  LM+LM LM+DM LV+M  LV+LM LV+V  LV+LV LV+LV
""".split(/\n/g).map (line) -> line.split(/\s+/g)

Options = {
  luma:
    dark:         ['Dark',  'Dark']
    darkish:      ['',      'Dark']
    darkening:    ['Light', 'Dark']
    darkened:     ['Dark',  '']

    light:        ['Light', 'Light']
    lightish:     ['',      'Light']
    lightening:   ['Dark',  'Light']
    lightened:    ['Light', '']

  saturation:
    muted:        ['Muted', 'Muted']
    saturating:   ['Muted', 'Vibrant']
    desaturating: ['Vibrant', 'Muted']
    vibrant:      ['Vibrant', 'Vibrant']

  #tone:
  #  dramatic:     ['Dramatic', 'Dramatic']
  #  dramatic:     ['Dramatic', 'Dramatic']
  #  original:     ['Original', 'Original']

}

properties = ['background', 'foreground', 'accent']

Schema = (name, lumas, saturations) ->
  options = {name: name, toString: CSS}
  for property, index in properties
    options[property] = Colors(index, lumas, saturations).filter (color) ->
      typeof color == 'string' && color.indexOf('undefined') == -1

  return (swatches, matrix, luma, saturation) ->
    Pallete swatches, matrix, luma, saturation, options

Schema.fromString = (name) ->
  lumas = saturations = null
  for bit, index in name.split('+')
    for letter in bit
      switch letter
        when 'D'
          (lumas ||= [])[index] = 'Dark'
        when 'L'
          (lumas ||= [])[index] = 'Light'
        when 'V'
          (saturations ||= [])[index] = 'Vibrant'
        when 'M'
          (saturations ||= [])[index] = 'Muted'
  return Schema(name, lumas, saturations)

# Pregenerate possible colors
Colors = (index, lumas, saturations) ->
  colors = []
  if index < 2
    luma = lumas?[index] || ''
    saturation = saturations?[index] || 'Muted'

    patterns = [
      !luma && saturation
      # Try matching both luma & saturation requirements
      luma + saturation, 
    ].concat(
      # Only match saturation requirement with regular luma
      if luma
        saturation
      else if lumas?.indexOf('Dark') == -1
        ['Dark' + saturation, 'Light' + saturation]
      else
        ['Light' + saturation, 'Dark' + saturation]
    ).concat(
      # Match luma requirement with other saturation
      luma + (saturation == 'Vibrant' && 'Muted' || 'Vibrant')
    )
    fallback = [

    ]
    return patterns
  else if saturations?.indexOf('Vibrant') > -1 && lumas
    return ['LightVibrant', 'Vibrant', 'DarkVibrant', 'LightMuted', 'DarkMuted']
  else
    return ['LightVibrant', 'Vibrant', 'DarkVibrant']

module.exports.debug = (swatches, matrix) ->
  list = document.createElement('dl')
  list.style.float = 'left'
  list.style.marginLeft = '20px'
  for own property, value of swatches
    if value
      dt = document.createElement('dt')
      dt.innerHTML = property
      dt.style.float = 'left'
      dt.style.clear = 'both'
      dt.style.width = '100px'
      dd = document.createElement('dd')
      dd.style.float = 'left'
      dd.style.height = '20px'
      for color in value
        span = document.createElement('span')
        span.style.display = 'inline-block'
        span.style.width = '20px'
        span.style.height = '20px'
        span.style.backgroundColor = color.toString()
        span.title = parseFloat(color.getPopulation())
        dd.appendChild(span)
      
      delimeted = false
      #for match, index in matrix[property]
      #  break if index > 1
      #  span = document.createElement('span')
      #  span.style.display = 'inline-block'
      #  span.style.borderRadius = '50%'
      #  span.style.width = '15px'
      #  span.style.height = '15px'
      #  span.style.height = '15px'
      #  span.title = match[1]
  #
      #  if match[1] < 4 && !delimeted
      #    span.style.width = '12px'
      #    span.style.height = '12px'
      #    span.style.marginLeft = '3px'
      #  span.style.backgroundColor = swatches[match[0]]?.toString()
      #  dd.appendChild(span)

      list.appendChild(dt)
      list.appendChild(dd)
  return list

module.exports.example = (colors, level) ->
  article = document.createElement('article')
  article.style.backgroundColor =  colors.background;
  article.style.width = '140px'
  article.style.padding = '10px'
  article.style.display = 'inline-block'
  article.style.verticalAlign = 'top'
  if level
    article.style.marginTop = 40 * (level - 1) + 'px'
    if level < 7
      article.style.marginRight = '-115px'
    else
      article.style.marginRight = '-80px'


  article.innerHTML = """
    <h1 style="color: #{colors.backgroundAA}; padding: 0; margin: 0 0 5px">#{colors.name}</h1>
    <p style="color: #{colors.backgroundAAA}; padding: 0; margin: 0 0 5px">#{colors.background.name}</p>
    <button style="margin: 0 -8px -10px -10px; padding: 5px 10px; border: 0; background: #{colors.accent}; color: #{colors.accentAAA}">#{colors.accent.name}</button>
    <section style="background-color: #{colors.foreground}; padding: 15px 10px 10px">
      <h1 style="color: #{colors.foregroundAA}; padding: 0; margin: 0 0 5px">Good title</h1>
      <p style="color: #{colors.foregroundAAA}; padding: 0; margin: 0">#{colors.foreground.name}</p>
    </section>
  """
  return article

CSS = (prefix) -> """
  #{prefix} {
    background-color: #{@background};
    color: #{@backgroundAAA};
  }
  #{prefix} h1,
  #{prefix} h2,
  #{prefix} h3 {
    color: #{@backgroundAA};
  }
  #{prefix} .block {
    background-color: #{@foreground};
    color: #{@foregroundAAA};
  }
  #{prefix} button,
  #{prefix} .accent {
    background-color: #{@accent};
    color: #{@accentAAA};
  }
  #{prefix} .block h1, 
  #{prefix} .block h2, 
  #{prefix} .block h3 {
    color: #{@foregroundAA};
  }
  #{prefix} picture:before {
    color: #{@background};
  }
  #{prefix} picture:after {
    color: #{@foreground};
  }
"""


Schemes = {}

do ->

  for row, i in Space
    for cell, j in row
      Schemes[cell] = Schema.fromString(cell)

  for saturation, saturations of Options.saturation
    Schemes[saturation] = Schema(saturation, null, saturations)

  for luma, lumas of Options.luma
    for saturation, saturations of Options.saturation
      Schemes[luma + saturation] = Schema(luma + saturation, lumas, saturations)
    Schemes[luma] = Schema(luma, lumas)

