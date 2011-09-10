fs = require('fs')

exports.fileExists = (path) ->
    try
        fs.statSync(path)
        true
    catch err
        false
