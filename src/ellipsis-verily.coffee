###
  A true plugin for text truncation.

  @autor Lisa-Ann Bruney <lisabruney@yahoo.com>
  @year 2014
###

class EllipsisVerily

  constructor: (element, options) ->
    defaults =
      max: 450
      handler: '.ellipsis-handler'
      visible: '.visible-text'
      truncated: '.truncated-text'
      ellipsis: '.ellipsis-text'
      hiddenClass: 'display-none'
      showClass: 'display-inline'
      activeClass: 'open'
      moreText: 'Read more'
      lessText: 'Show less'
      parent: null
      normalTags: ['p', 'span', 'strong', 'em', 'label', 'br', 'h1', 'h2', 'h3', 'h4', 'b', 'code', 'ul', 'li']
      attributedTags: ['a', 'img']

    @options = $.extend(defaults, options)
    @element = $(element)
    @tags = @options.normalTags.concat(@options.attributedTags)
    @normalTagCount = @options.normalTags.length
    @attributedTagCount = @options.attributedTags.length
    @tagsLength = {}
    @init()
    return this

  init: ->
    @placeHolderTags()
    @makeEllipsis()
    @setEvents()

  setEvents: ->
    that = @
    if (@options.parent)
      $parentsUntil = @element.parentsUntil(@options.parent)
      $parent = (if ($parentsUntil.length > 0) then $parentsUntil.parent() else @element.parent())
      @handler = $parent.find(@options.handler)
    else 
      @handler = $(@options.handler)
    @handler.click ->
      $element = $(@)
      $element.toggleClass(that.options.activeClass)

      if ($element.hasClass(that.options.activeClass))
        $element.text(that.options.lessText)
      else
        $element.text(that.options.moreText)

      that.element.find(that.options.ellipsis).toggleClass(that.options.hiddenClass).toggleClass(that.options.showClass)
      that.element.find(that.options.truncated).toggleClass(that.options.hiddenClass).toggleClass(that.options.showClass)
      return false
    return

  placeHolderTags: ->
    # Normalize text
    @html = @element.html().replace(/%[A-F\d]{2}/g, 'U')
    @attributedTag = {}
    i = 0
    while i < @normalTagCount
      @replaceTag(@tags[i])
      i++

    i = @normalTagCount
    while i < @normalTagCount + @attributedTagCount
      @replaceAttributedTag(@tags[i])
      i++

    @html = @stripOtherTags(@html)
    return

  stripOtherTags: (text) ->
    return text.replace(/(<([^>]+)>)/ig, '') # Doesn't support weird html like '<img alt="a>b" src="a_b.gif">'

  replaceAttributedTag: (tag) ->
    @attributedTag[tag] = $(tag)
    @html = @html.replace(@getRegex(@getTag(tag)), @getPlaceholderTag(tag)+@getPlaceholderTag(tag, false))
    return

  replaceTag: (tag) ->
    @html = @html.replace(@getRegex(@getTag(tag)), @getPlaceholderTag(tag))
    @html = @html.replace(@getRegex(@getTag(tag, false)), @getPlaceholderTag(tag, false))
    return

  replenishTag: (tag) ->
    @finalHtml = @finalHtml.replace(@getRegex(@getPlaceholderTag(tag)), @getTag(tag, true, true))
    @finalHtml = @finalHtml.replace(@getRegex(@getPlaceholderTag(tag, false)), @getTag(tag, false))
    return

  replenishAttributedTag: (tag) ->
    i = 0
    while i < @attributedTag[tag].length
      original = @attributedTag[tag][i].outerHTML
      inner = @attributedTag[tag][i].innerHTML
      placeholder = @getPlaceholderTag(tag)+@getPlaceholderTag(tag, false)+inner
      @finalHtml = @finalHtml.replace(@getRegex(placeholder), original)
      i++
    return

  getTag: (tag, opening = true, simple = false) ->
    if (opening)
      if (simple)
        return '<'+tag+'>'
      else
        return '<'+tag+'([^>]*)>'
    else 
      return '</'+tag+'>'

  getPlaceholderTag: (tag, opening = true) ->
    if (opening)
      return '{'+tag+'}'
    else 
      return '{/'+tag+'}'

  makeEllipsis: ->
    max = (@getTotalTags() * 5) + @options.max 
    if @html.length < max
      return

    # Find non-English text
    if @html.match(/[\u3400-\u9FBF]/)
      splitLocation = max/2
    else
      splitLocation = @html.indexOf(' ', max)
    if splitLocation > -1
      @half1 = @html.substr(0, splitLocation)
      @half2 = @html.substr(splitLocation, @html.length - 1)
      @findBreaks()
      @recreateHtml()
      @element.html(@finalHtml)
    else 
      return

  findBreaks: ->
    i = 0
    @brokenTags = {}
    while i < @normalTagCount
      tag = @tags[i]
      openingTag = @getPlaceholderTag(tag)
      openTags = @countOccurrences(openingTag)
      closeTags = @countOccurrences(@getPlaceholderTag(tag, false))
      if (openTags > closeTags)
        difference = openTags - closeTags
        @brokenTags[tag] = difference
        d = 0
        while d < difference
          @appendToTruncated(openingTag)
          # @moveToTruncated(@half1.lastIndexOf(openingTag))
          d++
      i++
    return

  recreateHtml: ->
    i = 0
    @finalHtml = '<div class="'+@options.visible.substr(1)+'">'+@half1+'<span class="'+@options.ellipsis.substr(1)+' '+@options.showClass+'">...</span></div><div class="'+@options.truncated.substr(1)+' '+@options.hiddenClass+'" >'+@half2+'</div>'
    while i < @normalTagCount
      @replenishTag(@tags[i])
      i++

    i = @normalTagCount
    while i < @normalTagCount + @attributedTagCount
      @replenishAttributedTag(@tags[i])
      i++
    return

  moveToTruncated: (from) ->
    temp = @half1.substr(from, @half1.length - 1)
    @half2 = temp + @half2
    @half1 = @half1.substr(0, from)
    return

  appendToTruncated: (placeHolderTag) ->
    @half2 = placeHolderTag + @half2

  countOccurrences: (tag) ->
    matches = @half1.match(@getRegex(tag))
    if (matches)
      return matches.length
    else 
      return 0

  getRegex: (tag) ->
    return new RegExp(tag, 'gi')

  getTotalTags: ->
    that = @
    totalTagsLength = 0
    $.each @tags, (key, value) ->
      length = that.element.find(value).length
      totalTagsLength = totalTagsLength + length
      that.tagsLength[value] = length
      return
    return totalTagsLength

  hasTag: (tag) ->
    return (that.tagsLength[tag] > 0)

  $.fn.EllipsisVerily = (options) ->
    $(this).each (i, element) ->
      $(this).data 'ellipsis-verily', new EllipsisVerily(this, options)  unless $(this).data('ellipsis-verily')
    return
