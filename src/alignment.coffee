module.exports = ->
	
	#for element in document.querySelectorAll('picture')
	#	img = element.getElementsByTagName('img')[0]
	#	img.style.clip = img.style.webkitClip = 'rect(' + (- img.offsetLeft) + 'px,' + (- img.offsetLeft + img.offsetWidth) + 'px,' + (- img.offsetLeft) + 'px,' + (element.offsetHeight) + 'px)'
	
	for element in document.querySelectorAll('.horizontal')
		list = getChildren(element)
		for child, index in list
			continue unless previous = list[index - 1]
			if child.offsetTop >= previous.offsetTop + previous.offsetHeight
				element.classList.add('actually-vertical')
				break

		module.exports.eachRow layout, (collection) ->
			pictures = collection.map (item) -> item.getElementsByTagName('picture')[0]

			for article, index in collection
				picture = pictures[index]

				if picture.offsetLeft > 0
					article.classList.add('partial-image')
				else
					article.classList.remove('partial-image')

				if collection.length == 1
					article.classList.add('full')
				else
					article.classList.remove('full')

			basis = parseFloat(picture.style.maxWidth)
			#if element.classList.contains('vertical') || element.classList.contains('actually-vertical')
			#	if basis / window.innerWidth > 0.9
			#		element.style.flexBasis = element.style.webkitFlexBasis = '100%'
			#	else if basis / window.innerWidth > 0.7
			#		element.style.flexBasis = element.style.webkitFlexBasis = '75%'
			#	else if basis / window.innerWidth > 0.66
			#		element.style.flexBasis = element.style.webkitFlexBasis = '66%'
			#	else if basis / window.innerWidth > 0.4
			#		element.style.flexBasis = element.style.webkitFlexBasis = '50%'
			#	else if basis / window.innerWidth
			#		element.style.flexBasis = element.style.webkitFlexBasis = '25%'

	for element in document.querySelectorAll('.x-aligned')
		if element.classList.contains('actually-vertical') || element.classList.contains('vertical')
			continue

		module.exports.eachRow element, (collection) ->

			if collection.length == 2
				left = collection[0].offsetLeft
				right = element.offsetWidth  - collection[1].offsetLeft - collection[1].offsetWidth
				span = left + right

				if element.classList.contains('inverted')
					offset = collection[0].offsetWidth + collection[0].offsetLeft - element.offsetWidth / 2
					
					if span >= offset
						if offset > 0
							element.style.paddingRight = Math.min(span, Math.abs(offset)) + 'px'
						else
							element.style.paddingLeft = Math.min(span, Math.abs(offset)) + 'px'
				else
					offset = element.offsetWidth / 2 - collection[0].offsetWidth
					if span >= Math.abs(offset)
						if offset > 0
							element.style.paddingLeft = Math.abs(offset) + 'px'
						else
							element.style.paddingRight = Math.abs(offset) + 'px'

	return

module.exports.eachRow = (element, callback) ->
	collection = null
	list = getChildren(element)
	i = 0
	for child, index in list
		continue unless previous = list[index - 1]
		collection ||= [previous]
		if child.offsetTop < previous.offsetTop + previous.offsetHeight
			collection.push(child)
		else
			callback(collection, i++)
			collection = [child]

		if list[index + 1]
			continue

		callback(collection, i++)
		collection = null
	return

module.exports.reset = ->
	for element in document.querySelectorAll('.x-aligned')
		element.style.paddingLeft = element.style.paddingRight = ''
	for el in document.querySelectorAll('article')
		el.style.webkitFlexBasis = el.style.flexBasis = ''
	for el in document.querySelectorAll('.actually-horizontal, .actually-vertical')
		el.classList.remove('actually-vertical')
		el.classList.remove('actually-horizontal')

	module.exports()
	#module.exports()

getChildren = (element) ->
  if element.classList.contains('inverted')
    list = Array.prototype.reverse.call(Array.prototype.slice.call(element.children))
  else
    list = Array.prototype.slice.call(element.children)

  return list.filter (el) -> el.tagName != 'STYLE'

window.addEventListener('resize', module.exports.reset)
window.addEventListener('load', module.exports)
