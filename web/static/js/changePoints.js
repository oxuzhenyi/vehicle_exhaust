self.onmessage = function( ev ) {
  var aAllPoints = ev.data;// data是所有热点的数组，某一热点包括count，lng，lat
  
  for ( var i = 0,len = aAllPoints.length; i < len; i++ ) {
      aAllPoints[i].count += Math.round( ( Math.random() - 0.5 ) * 0.4 * aAllPoints[i].count );
  }
  
  self.postMessage( aAllPoints );
}

/*function randomArr( arr, count ) {
  var newArr = [];
  for ( var i = 0,  i < count; i++ ) {
    newArr.push(arr.splice( arr[Math.floor( Math.random() * arr.length )], 1)); 
  }
  
  return newArr;
}*/
