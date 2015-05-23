Ellipsis Verily
================

JQuery plugin for text truncation supporting inner tags ([demo](http://lbruney.github.io/ellipsis-verily/demo/index.html)).

Usage
================
* Add JQuery script to page
* Add Ellipsis Verily script to page
* Call plugin on the to be truncated element:
```
  $('.to-be-truncated').EllipsisVerily();
```


API
================
`max (int)`:              maximum number of characters  
`handler (string)`:       the element class/id that toggles between the truncation  
`visible (string)`:       the element class/id that is visible after truncation  
`truncated (string)`:     the element class/id that is truncated  
`ellipsis (string)`:      the element class/id that holds the ellipsis symbol  
`hiddenClass (string)`:   the class name whose style is set to display: none;  
`showClass (string)`:     the class name whose style is set to display: inline|block;  
`moreText (string)`:      the text to show on the handler when text is truncated  
`lessText (string)`:      the text to show on the handler when all text is visible  
`parent (string)`:        the element class/id of the parent where the handler can be found (useful if multiple containers are to be truncated which all have the same handler class name)  
`normalTags (array)`:     list of tags that are to be included but attributes are to be stripped  
`attributedTags (array)`: list of tags that are to be included but attributes are not to be stripped  


Limitations
================
* Html attributes like: alt="a>b" not supported.
* Tags separated by the truncation point are moved into the truncated container.

## License

[MIT](LICENSE)
