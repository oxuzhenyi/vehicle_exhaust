self.onmessage = function ( ev ) {
  
  var 
    point = ev.data.point,
    swLng = ev.data.swLng,
    neLng = ev.data.neLng,
    swLat = ev.data.swLat,
    neLat = ev.data.neLat
  ;
//console.log(ev);
  var arr = randomArr( point, swLng, neLng, swLat, neLat );
  self.postMessage( arr );
}

function randomArr( point, swLng, neLng, swLat, neLat ) {/*固定数据格式，所以没必要封装成一个对象，当然，封装成一个对象更简洁*/
  var 
    lngSpan = Math.abs(swLng - neLng),
    latSpan = Math.abs(swLat - neLat),
    aPoints = [],
    pointObj = {}
  ;
  for (var i = 0; i < 20; i++) {
    pointObj = {
      lng : point.lng + lngSpan * ( Math.random() - 0.5 ) * 1,
      lat : point.lat + latSpan * ( Math.random() - 0.5 ) * 1,
      count : Math.ceil(Math.random() * 100)
    }
    aPoints.push(pointObj);
  }
  
  return aPoints;
}
