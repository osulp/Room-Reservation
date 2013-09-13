Date.prototype.toLocalISOString = function(){
    // ISO 8601
    var d = this
        , pad = function (n){return n<10 ? '0'+n : n}
        , tz = d.getTimezoneOffset() //mins
        , tzs = (tz>0?"-":"+") + pad(parseInt(tz/60))

    if (tz%60 != 0)
        tzs += pad(tz%60)

    if (tz === 0) // Zulu time == UTC
        tzs = 'Z'

    return d.getFullYear()+'-'
        + pad(d.getMonth()+1)+'-'
        + pad(d.getDate())+'T'
        + pad(d.getHours())+':'
        + pad(d.getMinutes())+':'
        + pad(d.getSeconds()) + tzs
}