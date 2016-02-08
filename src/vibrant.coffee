###
  Vibrant.js
  by Jari Zwarts
  Color algorithm class that finds variations on colors in an image.
  Credits
  --------
  Lokesh Dhakar (http://www.lokeshdhakar.com) - Created ColorThief
  Google - Palette support library in Android
###

window.Swatch = class Swatch
  hsl: undefined
  rgb: undefined
  population: 1
  @yiq: 0

  constructor: (rgb, population) ->
    @rgb = rgb.map (value) -> Math.floor(value)
    @population = population

  getHsl: ->
    if not @hsl
      @hsl = Vibrant.rgbToHsl @rgb[0], @rgb[1], @rgb[2]
    else @hsl

  getPopulation: ->
    @population

  getRgb: ->
    @rgb

  toString: ->
    'rgb(' + @rgb.join(', ') + ')'

  getHex: ->
    "#" + ((1 << 24) + (@rgb[0] << 16) + (@rgb[1] << 8) + @rgb[2]).toString(16).slice(1, 7);

  getTitleTextColor: ->
    @_ensureTextColors()
    if @yiq < 200 then "#fff" else "#000"

  getBodyTextColor: ->
    @_ensureTextColors()
    if @yiq < 150 then "#fff" else "#000"

  _ensureTextColors: ->
    if not @yiq then @yiq = (@rgb[0] * 299 + @rgb[1] * 587 + @rgb[2] * 114) / 1000

window.Vibrant = class Vibrant

  quantize: require('quantize')
  rgbquant: require('rgbquant')

  _swatches: []

  TARGET_DARK_LUMA: 0.26
  MAX_DARK_LUMA: 0.45
  MIN_LIGHT_LUMA: 0.55
  TARGET_LIGHT_LUMA: 0.74

  MIN_NORMAL_LUMA: 0.3
  TARGET_NORMAL_LUMA: 0.5
  MAX_NORMAL_LUMA: 0.7

  TARGET_MUTED_SATURATION: 0.3
  MAX_MUTED_SATURATION: 0.4

  TARGET_VIBRANT_SATURATION: 1
  MIN_VIBRANT_SATURATION: 0.35

  WEIGHT_SATURATION: 5
  WEIGHT_LUMA: 6
  WEIGHT_POPULATION: 1

  VibrantSwatch: undefined
  MutedSwatch: undefined
  DarkVibrantSwatch: undefined
  DarkMutedSwatch: undefined
  LightVibrantSwatch: undefined
  LightMutedSwatch: undefined

  HighestPopulation: 0

  constructor: (sourceImage, colorCount, quality) ->
    if typeof colorCount == 'undefined'
      colorCount = 64
    if typeof quality == 'undefined'
      quality = 5

    try
      if @rgbquant
        opts = {
          colors: 96,             # desired palette size
          method: 2,               # histogram method, 2: min-population threshold within subregions; 1: global top-population
          boxSize: [32,32],        # subregion dims (if method = 2)
          boxPxls: 2,              # min-population threshold (if method = 2)
          initColors: 4096,        # # of top-occurring colors  to start with (if method = 1)
          minHueCols: 256,           # # of colors per hue group to evaluate regardless of counts, to retain low-count hues
          dithKern: null,          # dithering kernel name, see available kernels in docs below
          dithDelta: 0,            # dithering threshhold (0-1) e.g: 0.05 will not dither colors with <= 5% difference
          dithSerp: false,         # enable serpentine pattern dithering
          palette: [],             # a predefined palette to start with in r,g,b tuple format: [[r,g,b],[r,g,b]...]
          reIndex: false,          # affects predefined palettes only. if true, allows compacting of sparsed palette once target palette size is reached. also enables palette sorting.
          useCache: true,          # enables caching for perf usually, but can reduce perf in some cases, like pre-def palettes
          cacheFreq: 10,           # min color occurance count needed to qualify for caching
          colorDist: "euclidean",  # method used to determine color distance, can also be "manhattan"
        }

        q = new @rgbquant(opts)
        q.sample(sourceImage)
        pallete = q.palette(true, true)
        @_swatches = pallete.slice(0, 64).map (color, index) =>
          new Swatch color, pallete.length - index

      else
        image = new CanvasImage(sourceImage)

        imageData = image.getImageData()
        pixels = imageData.data
        pixelCount = image.getPixelCount()

        allPixels = []
        i = 0
        while i < pixelCount
          offset = i * 4
          r = pixels[offset + 0]
          g = pixels[offset + 1]
          b = pixels[offset + 2]
          a = pixels[offset + 3]
          # If pixel is mostly opaque and not white
          if a >= 125
            if not (r > 250 and g > 250 and b > 250)
              allPixels.push [r, g, b]
          i = i + quality


        cmap = @quantize allPixels, colorCount
        @_swatches = cmap.vboxes.map (vbox) =>
          new Swatch vbox.color, vbox.vbox.count()

      @maxPopulation = @findMaxPopulation()

      @generateVarationColors()
      #@generateEmptySwatches()

    # Clean up
    finally
      image?.removeCanvas()

  NotYellow: (hsl) ->
    #if hsl[2] < 0.5
    #  return false
    return true#hsl[0] < 50 || hsl[0] > 63

  generateVarationColors: ->
    for i in [1 ... 4]
      if i == 1
        i = ''
      @['LightVibrantSwatch' + i] = @findColorVariation(@TARGET_LIGHT_LUMA, @MIN_LIGHT_LUMA, 1,
        @TARGET_VIBRANT_SATURATION, @MIN_VIBRANT_SATURATION, 1, 'LightVibrantSwatch');

      @['VibrantSwatch' + i] = @findColorVariation(@TARGET_NORMAL_LUMA, @MIN_NORMAL_LUMA, @MAX_NORMAL_LUMA,
        @TARGET_VIBRANT_SATURATION, @MIN_VIBRANT_SATURATION, 1, 'VibrantSwatch', @NotYellow);

      @['DarkVibrantSwatch' + i] = @findColorVariation(@TARGET_DARK_LUMA, 0, @MAX_DARK_LUMA,
        @TARGET_VIBRANT_SATURATION, @MIN_VIBRANT_SATURATION, 1, 'DarkVibrantSwatch', @NotYellow);

      @['LightMutedSwatch' + i] = @findColorVariation(@TARGET_LIGHT_LUMA, @MIN_LIGHT_LUMA, 1,
        @TARGET_MUTED_SATURATION, 0, @MAX_MUTED_SATURATION, 'LightMutedSwatch');

      @['MutedSwatch' + i] = @findColorVariation(@TARGET_NORMAL_LUMA, @MIN_NORMAL_LUMA, @MAX_NORMAL_LUMA,
        @TARGET_MUTED_SATURATION, 0, @MAX_MUTED_SATURATION, 'MutedSwatch', @NotYellow);

      @['DarkMutedSwatch' + i] = @findColorVariation(@TARGET_DARK_LUMA, 0, @MAX_DARK_LUMA,
        @TARGET_MUTED_SATURATION, 0, @MAX_MUTED_SATURATION, 'DarkMutedSwatch');

  generateEmptySwatches: ->
    for Target, value of @
      if Target.indexOf('Swatch') > -1 && Target.indexOf(3) == -1
        unless value?

          if Target.indexOf('Light') > -1
            lights = ['Dark', 'Regular', 'Light']
            luma = @TARGET_LIGHT_LUMA
          else if Target.indexOf('Dark') > -1
            lights = ['Regular', 'Light', 'Dark']
            luma = @TARGET_DARK_LUMA
          else 
            lights = ['Light', 'Dark', 'Regular']
            luma = @TARGET_NORMAL_LUMA

          if Target.indexOf('Muted') > -1
            vibrances = ['Vibrant', 'Muted']
            saturation = @TARGET_MUTED_SATURATION
          else
            vibrances = ['Muted', 'Vibrant']
            saturation = @TARGET_VIBRANT_SATURATION

          if Target.indexOf('2') > -1
            numbers = [2, 1]
          else
            numbers = [1, 2]

          for number in numbers
            for light in lights
              for vibrance in vibrances
                Source =  (light != 'Regular' && light || '') + 
                          (vibrance + 'Swatch') + 
                          (number == 2 && '2' || '')
                if @[Source]
                  hsl = @[Source].getHsl()?.slice()
                  if light == 'Regular'
                    if Target.match(/Light|Dark/)
                      hsl[2] = luma
                  else if Target.indexOf(light) == -1
                    hsl[2] = luma

                  hsl[1] = saturation
                  @[Target] = new Swatch Vibrant.hslToRgb(hsl[0], hsl[1], hsl[2]), 0
                  break

  findMaxPopulation: ->
    population = 0
    population = Math.max(population, swatch.getPopulation()) for swatch in @_swatches
    population

  findColorVariation: (targetLuma, minLuma, maxLuma, targetSaturation, minSaturation, maxSaturation, label, filter) ->
    max = undefined
    maxValue = 0

    for swatch in @_swatches
      hue = swatch.getHsl()[0];
      sat = swatch.getHsl()[1];
      luma = swatch.getHsl()[2]

      if filter
        continue if filter.call(@, hue) == false

      if sat >= minSaturation and sat <= maxSaturation and
        luma >= minLuma and luma <= maxLuma and
        not @isAlreadySelected(swatch) && swatch.getPopulation() > 2
          hueDiff = 0
          total = 0
          if label
            for name, other of @
              if other && name.indexOf(label) > -1
                total++
                hueDiff += Math.abs(other.getHsl()[0] - hue)
          if total
            hueDiff /= total
          value = @createComparisonValue sat, targetSaturation, luma, targetLuma, hueDiff,
            swatch.getPopulation(), @maxPopulation
          if max is undefined or value > maxValue
            max = swatch
            maxValue = value
    max?.name = label.replace('Switch', '')
    max

  createComparisonValue: (saturation, targetSaturation,
      luma, targetLuma, hueDiff, population, maxPopulation) ->
    @weightedMean(
      @invertDiff(saturation, targetSaturation), @WEIGHT_SATURATION,
      @invertDiff(luma, targetLuma), @WEIGHT_LUMA,
      population / maxPopulation, @WEIGHT_POPULATION,
      hueDiff, 1
    )

  invertDiff: (value, targetValue) ->
    1 - Math.abs value - targetValue

  weightedMean: (values...) ->
    sum = 0
    sumWeight = 0
    i = 0
    while i < values.length
      value = values[i]
      weight = values[i + 1]
      sum += value * weight
      sumWeight += weight
      i += 2
    sum / sumWeight

  swatches: =>
    result = {}
    for property, value of @
      if typeof value == 'object' && property.indexOf('Swatch') > -1
        (result[property.replace('Swatch', '').replace(/\d+$/, '')] ||= []).push value
    return result

  isAlreadySelected: (swatch) ->
    for property, value of @
      if value == swatch
        return true

  @rgbToHsl: (r, g, b) ->
    r /= 255
    g /= 255
    b /= 255
    max = Math.max(r, g, b)
    min = Math.min(r, g, b)
    h = undefined
    s = undefined
    l = (max + min) / 2
    if max == min
      h = s = 0
      # achromatic
    else
      d = max - min
      s = if l > 0.5 then d / (2 - max - min) else d / (max + min)
      switch max
        when r
          h = (g - b) / d + (if g < b then 6 else 0)
        when g
          h = (b - r) / d + 2
        when b
          h = (r - g) / d + 4
      h /= 6
    [h, s, l]

  @hslToRgb: (h, s, l) ->
    r = undefined
    g = undefined
    b = undefined

    hue2rgb = (p, q, t) ->
      if t < 0
        t += 1
      if t > 1
        t -= 1
      if t < 1 / 6
        return p + (q - p) * 6 * t
      if t < 1 / 2
        return q
      if t < 2 / 3
        return p + (q - p) * (2 / 3 - t) * 6
      p

    if s == 0
      r = g = b = l
      # achromatic
    else
      q = if l < 0.5 then l * (1 + s) else l + s - (l * s)
      p = 2 * l - q
      r = hue2rgb(p, q, h + 1 / 3)
      g = hue2rgb(p, q, h)
      b = hue2rgb(p, q, h - (1 / 3))
    [
      r * 255
      g * 255
      b * 255
    ]


###
  CanvasImage Class
  Class that wraps the html image element and canvas.
  It also simplifies some of the canvas context manipulation
  with a set of helper functions.
  Stolen from https://github.com/lokesh/color-thief
###

window.CanvasImage = class CanvasImage
  constructor: (image) ->
    @canvas = document.createElement('canvas')
    @context = @canvas.getContext('2d')
    document.body.appendChild @canvas
    @width = @canvas.width = image.width
    @height = @canvas.height = image.height
    @context.drawImage image, 0, 0, @width, @height

  clear: ->
    @context.clearRect 0, 0, @width, @height

  update: (imageData) ->
    @context.putImageData imageData, 0, 0

  getPixelCount: ->
    @width * @height

  getImageData: ->
    @context.getImageData 0, 0, @width, @height

  removeCanvas: ->
    @canvas.parentNode.removeChild @canvas