###
  A true plugin for text truncation.

  @autor Lisa-Ann Bruney <lisabruney@yahoo.com>
  @year 2014
###

(($) ->
  'use scrict'
  EllipsisVerily = (element, options) ->
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
    return

  EllipsisVerily::init = ->
    @placeHolderTags()
    @makeEllipsis()
    @setEvents()
    return

  EllipsisVerily::setEvents = ->
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

  EllipsisVerily::placeHolderTags = ->
    @html = @element.html()
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

  EllipsisVerily::stripOtherTags =(text) ->
    return text.replace(/(<([^>]+)>)/ig, '') # Doesn't support weird html like '<img alt="a>b" src="a_b.gif">'

  EllipsisVerily::replaceAttributedTag =(tag) ->
    @attributedTag[tag] = $(tag)
    @html = @html.replace(@getRegex(@getTag(tag)), @getPlaceholderTag(tag)+@getPlaceholderTag(tag, false))
    return

  EllipsisVerily::replaceTag =(tag) ->
    @html = @html.replace(@getRegex(@getTag(tag)), @getPlaceholderTag(tag))
    @html = @html.replace(@getRegex(@getTag(tag, false)), @getPlaceholderTag(tag, false))
    return

  EllipsisVerily::replenishTag =(tag) ->
    @finalHtml = @finalHtml.replace(@getRegex(@getPlaceholderTag(tag)), @getTag(tag, true, true))
    @finalHtml = @finalHtml.replace(@getRegex(@getPlaceholderTag(tag, false)), @getTag(tag, false))
    return

  EllipsisVerily::replenishAttributedTag =(tag) ->
    i = 0
    while i < @attributedTag[tag].length
      original = @attributedTag[tag][i].outerHTML
      inner = @attributedTag[tag][i].innerHTML
      placeholder = @getPlaceholderTag(tag)+@getPlaceholderTag(tag, false)+inner
      @finalHtml = @finalHtml.replace(@getRegex(placeholder), original)
      i++
    return

  EllipsisVerily::getTag =(tag, opening = true, simple = false) ->
    if (opening)
      if (simple)
        return '<'+tag+'>'
      else
        return '<'+tag+'([^>]*)>'
    else 
      return '</'+tag+'>'

  EllipsisVerily::getPlaceholderTag =(tag, opening = true) ->
    if (opening)
      return '{'+tag+'}'
    else 
      return '{/'+tag+'}'

  EllipsisVerily::makeEllipsis = ->
    max = (@getTotalTags() * 5) + @options.max 
    if @html.length < max
      return
    splitLocation = @html.indexOf(' ', max)
    @half1 = @html.substr(0, splitLocation)
    @half2 = @html.substr(splitLocation, @html.length - 1)
    @findBreaks()
    @recreateHtml()
    @element.html(@finalHtml)
    return

  EllipsisVerily::findBreaks = ->
    i = 0
    while i < @normalTagCount
      openingTag = @getPlaceholderTag(@tags[i])
      openTags = @countOccurrences(openingTag)
      closeTags = @countOccurrences(@getPlaceholderTag(@tags[i], false))
      if (openTags > closeTags)
        difference = openTags - closeTags
        d = 0
        while d < difference
          @moveToTruncated(@half1.lastIndexOf(openingTag))
          d++
      i++
    return

  EllipsisVerily::recreateHtml = ->
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

  EllipsisVerily::moveToTruncated =(from) ->
    temp = @half1.substr(from, @half1.length - 1)
    @half2 = temp + @half2
    @half1 = @half1.substr(0, from)
    return

  EllipsisVerily::countOccurrences =(tag) ->
    matches = @half1.match(@getRegex(tag))
    if (matches)
      return matches.length
    else 
      return 0

  EllipsisVerily::getRegex =(tag) ->
    return new RegExp(tag, 'gi')

  EllipsisVerily::getTotalTags = ->
    that = @
    totalTagsLength = 0
    $.each @tags, (key, value) ->
      length = that.element.find(value).length
      totalTagsLength = totalTagsLength + length
      that.tagsLength[value] = length
      return
    return totalTagsLength

  EllipsisVerily::hasTag =(tag) ->
    return (that.tagsLength[tag] > 0)

  $.fn.EllipsisVerily = (options) ->
    $(this).each (i, element) ->
      $(this).data 'ellipsis-verily', new EllipsisVerily(this, options)  unless $(this).data('ellipsis-verily')
    return

  return
) jQuery