reqwest = require('reqwest')
domReady = require('domready')

callApi = (url, cb, data) -> 
    reqwest({
        headers: {'Content-Type': 'application/json'},
        url: url,
        method: if data then 'PUT' else 'GET',
        data: data || null
        type:'json',
        success: (resp) -> cb(resp)
    })

domReady ->
    callApi '/items', (items) ->
        _drawItems(document.getElementById('posts'), items)

        setTimeout(->
                window.scrollTo(0, 0)
                callApi('/pos', (pos) ->
                    pos = parseInt(pos, 10)
                    e = document.getElementById(pos)
                    if pos and e and e.offsetTop
                        console.log pos, e, e.offsetTop
                        window.scrollTo(0, e.offsetTop)

                    timer = null
                    window.onscroll = ->
                        if timer then clearTimeout(timer)
                        timer = setTimeout(_saveScroll, 1000)
                )
            , 100)


_drawItems = (parent, items) ->
    for item, i in items
        elem = _drawItem(item)
        elem.id = i
        parent.appendChild(elem)

_drawItem = (item) ->
    d = document.createElement('div')
    d.className = 'p'

    date = new Date(item.created)
    date_str = date.toDateString() + ' ' + date.toLocaleTimeString()

    permalink = date_str
    if item.source != null
        permalink = """
        <a href="#{item.source}">#{date_str}</a>
        """
    d.innerHTML = """
        <span class="u">#{item.name}</span>
        <span class="d">#{permalink}</span>
        <div class="m">#{item.message}</div>
        """
    return d

_saveScroll = ->
    TOP = 26
    elem = document.elementFromPoint(100, TOP)
    while not elem.parentNode
        elem = document.elementFromPoint(100, TOP)

    while elem.parentNode and elem.className isnt 'p'
        elem = elem.parentNode

    if elem.id
        console.log elem.id
        callApi('/pos', (->), elem.id)
    return
