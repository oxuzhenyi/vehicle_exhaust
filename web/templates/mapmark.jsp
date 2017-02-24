<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <head>
<!-- 版本说明，实现搜索框输入（还未实现按地址搜索）及热力图显示 -->
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
     <link href="http://api.map.baidu.com/library/TrafficControl/1.4/src/TrafficControl_min.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="http://api.map.baidu.com/library/SearchInfoWindow/1.5/src/SearchInfoWindow_min.css" />
    
    <script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=FwYgCRgu4aYk2YlWZRvYPbXu1q9qAx3e"></script>
    
    <script src="http://libs.baidu.com/jquery/2.0.0/jquery.min.js"></script>
<script type="text/javascript" src="http://api.map.baidu.com/library/Heatmap/2.0/src/Heatmap_min.js"></script>
<!-- 加载城市列表 -->
<script type="text/javascript" src="http://api.map.baidu.com/library/CityList/1.2/src/CityList_min.js"></script>
<!-- 加载百度地图样式信息窗口 -->
<script type="text/javascript" src="http://api.map.baidu.com/library/SearchInfoWindow/1.5/src/SearchInfoWindow_min.js"></script>

<!-- 实时路况 --> 
<script type="text/javascript" src="http://api.map.baidu.com/library/TrafficControl/1.4/src/TrafficControl_min.js"></script>
  
    <title>热力图功能示例</title>
    <style type="text/css">
    ul{list-style: none;margin:0;padding:0;float:left;}
    html{height:100%}
    body{height:100%;margin:0px;padding:0px;font-family:"微软雅黑";}
    #map{height:300px;width:100%;}
    #r-result{width:100%;}
      li{
      line-height:28px;
    }
    .cityList{
      height: 320px;
      width:372px;
      overflow-y:auto;
    }
    .sel_container{
      z-index:9999;
      font-size:12px;
      position:absolute;
      right:0px;
      top:45px;
      width:140px;
      background:rgba(255,255,255,0.8);
      height:20px;
      line-height:30px;
      padding:5px;
    }
    .map_popup {
      position: absolute;
      z-index: 200000;
      width: 382px;
      height: 344px;
      right:0px;
      top:40px;
    }
    .map_popup .popup_main { 
      background:#fff;
      border: 1px solid #8BA4D8;
      height: 100%;
      overflow: hidden;
      position: absolute;
      width: 100%;
      z-index: 2;
    }
    .map_popup .title {
      background: url("http://map.baidu.com/img/popup_title.gif") repeat scroll 0 0 transparent;
      color: #6688CC;
      font-weight: bold;
      height: 24px;
      line-height: 25px;
      padding-left: 7px;
    }
    .map_popup button {
      background: url("http://map.baidu.com/img/popup_close.gif") no-repeat scroll 0 0 transparent;
      cursor: pointer;
      height: 12px;
      position: absolute;
      right: 4px;
      top: 6px;
      width: 12px;
    } 
    table.map_data_table {
      width:100%;
      border-collapse: collapse;
    }
    table.map_data_table td {
      padding:5px 0;
      text-align: center;
      border:1px solid #ccc;
    }
    table.map_data_table thead tr {
      font-weight:bold;
    }
/*     table.map_data_table tbody tr {
      background:#ccc;
      transition: background .3s ease;
    } */
    table.map_data_table td a {
      text-decoration: none;
      color: #999;
    }
    
    table.map_data_table td a:hover {
      color: #000;
      font-weight: bold;
      cursor: pointer;
      transition: color .3s ease;
    }
    
    .tangram-suggestion {
      display:none;
    }
    #tangram-suggestion--TANGRAM__2a-main {
      display:none;
    }
    #r-result {
      margin: 20px 0;
      text-align: center;
    }
    #r-result input {
      display: inline-block;
      outline: none;
      padding:10px 5px;
      border: 1px solid #ccc;
    }
    
    #r-result input:focus {
      outline: auto;
    }
    
    #r-result input:nth-of-type(1) {
      width: 150px;
      border-radius: 4px 0 0 4px;
    }
    
    #r-result input:nth-of-type(2) {
      cursor: pointer;
      border-radius: 0 4px 4px 0;
    }
    
    tr.normal {
      background: #fff;
      transition: color .3s ease;
    }
    
    tr.normal>a {
      background: #999;
    }
    
    tr.active {
      background: #57A7EE;
      transition: color .3s ease;
    }
    
    tr.active td>a {
      color: #fff;
    }

    </style>  
  </head>
  
<body>
  <div class="demo_main">
    <fieldset class="demo_title">
        城市路网机动车尾气遥感监测系统
    </fieldset>
    <fieldset class="demo_content">
      <div id="selectoptions">
        &nbsp 检测点城市选择：
        <select id="sele" name="sele" onChange="watchModule.map_init(this.value)">  
          <option value="1" >北京</option>  
          <option value="2" selected>合肥</option>  
          <option value="3">广州</option>  
          <option value="4">西安</option>  
          </select> 
          <span class="input-group-addon">时间范围：</span>
              <input type="date" class="form-control"/>
              <span class="input-group-btn">
                <input type="date" class="form-control"/>
              </span>
      </div>
    </fieldset>
    
    <div id="map"></div>
    <div id="r-result">
            请输入监测点:
      <input type="text" id="suggestId" placeholder="请输入监测点id"/><input type="button" value="搜索" onclick="watchModule.searchWatchPoint()"/>
    </div>
    <!--城市列表-->
    <div class="sel_container"><strong id="curCity">合肥市</strong> [<a id="curCityText" href="javascript:void(0)">选择布点城市</a>]</div>
    <div class="map_popup" id="cityList" style="display:none;">
      <div class="popup_main">
        <div class="title">遥测布点城市列表</div>
        <div class="cityList" id="citylist_container"></div>
        <button id="popup_close"></button>
      </div>
    </div>
  </div>
  

  <!-- 表格显示相关数据 -->
  <table class="map_data_table">
    <thead>
      <tr>
        <td>ID</td>
        <td>监测点</td>
        <td>经纬度</td>
        <td>检测车辆数</td>
        <td>超标车辆数</td>
      </tr>
    </thead>
    <tbody id="tbody">
      
    </tbody>
  </table>
 

<script type="text/javascript">

  var watchModule = (function () {
    var 
      sel=2,
      lont =117.237603,lat=31.847239, //地图中心点，经度，纬度
      count = 0,/*用来标志表格中行的数量*/
      markerArr = [
        { title: "合肥黄山路检测点", point: "117.237603,31.847239", address: "69", tel: "12" },
        { title: "五里墩立交桥", point: "117.25715,31.858894", address: "124", tel: "18" },
        { title: "万达广场", point: "117.219206,31.826993", address: "62", tel: "10" },
        { title: "明光路", point: "117.311192,31.875822", address: "90", tel: "14" }
      ],
      aPoints = [],
      aAllPoints = []
      /*建立地图*/
     
    ;
    window.requestAnimationFrame = 
      window.requestAnimationFrame ||
      window.mozRequestAnimationFrame || 
      window.webkitRequestAnimationFrame || 
      window.msRequestAnimationFrame;
    
    
    function map_init(val) {
      count = 0;
      if(val != null) sel = val;
      switch(sel * 1) {
        case 1:
          lont = 116.768419, lat = 39.941051;//地图中心点，经度，纬度
          markerArr = [
//          { title: "妫水南街", point: "115.991874,40.447428", address: "74", tel: "10" },数据似乎有误？调试的时候不出现！
            { title: "三惠东桥", point: "116.719949,39.929264", address: "71", tel: "16" },
            { title: "白庙立交桥", point: "116.768419,39.941051", address: "39", tel: "10" }
         ];break;
        case 2:
          lont =117.237603,lat=31.847239; //地图中心点，经度，纬度
          markerArr = [
            { title: "合肥黄山路检测点", point: "117.237603,31.847239", address: "69", tel: "12" },
            { title: "五里墩立交桥", point: "117.25715,31.858894", address: "124", tel: "18" },
            { title: "万达广场", point: "117.219206,31.826993", address: "62", tel: "10" },
            { title: "明光路", point: "117.311192,31.875822", address: "90", tel: "14" }
          ];break;
        case 3:
        case 4:
          lont=113.312213,lat=23.147267;
          markerArr = [
            { title: "广州火车站", point: "113.264531,23.157003", address: "26", tel: "6" },
            { title: "广州塔（赤岗塔）", point: "113.330934,23.113401", address: "34 ", tel: "5" },
            { title: "广州动物园", point: "113.312213,23.147267", address: "67", tel: "18" },
            { title: "天河公园", point: "113.372867,23.134274", address: "23", tel: "1" }
        ];break;

      }
      /*
       * content: 将内容显示在表格
       * author: yuwanlin
       * */
      setTableContent(markerArr);
      
       map = new BMap.Map("map");
      //第1步：设置地图中心点，合肥市
      var point = new BMap.Point(lont,lat); //地图中心点
      //第2步：初始化地图,设置中心点坐标和地图级别。
      map.centerAndZoom(point, 13);
      //第3步：启用滚轮放大缩小
      map.enableScrollWheelZoom(true);
      //第4步：向地图中添加缩放控件
      var ctrlNav = new window.BMap.NavigationControl({
          anchor: BMAP_ANCHOR_TOP_LEFT,
          type: BMAP_NAVIGATION_CONTROL_LARGE
      });
      map.addControl(ctrlNav);
      //第5步：向地图中添加缩略图控件
      var ctrlOve = new window.BMap.OverviewMapControl({
          anchor: BMAP_ANCHOR_BOTTOM_RIGHT,
          isOpen: 1
      });
      map.addControl(ctrlOve);

      //第6步：向地图中添加比例尺控件
      var ctrlSca = new window.BMap.ScaleControl({
          anchor: BMAP_ANCHOR_BOTTOM_LEFT
      });
      map.addControl(ctrlSca);
                  
      //建立一个自动完成的对象
      var ac = new BMap.Autocomplete({
        "input" : "suggestId",
        "location" : map
      });
     //是否显示路况提示面板
       var ctrl4 = new BMapLib.TrafficControl({
        showPanel: true 
      });      
      map.addControl(ctrl4);
      ctrl4.setAnchor(BMAP_ANCHOR_BOTTOM_RIGHT);
          /*
         var ctrl = new BMapLib.TrafficControl({
              showPanel: true 
          });      
          map.addControl(ctrl);
          ctrl.setAnchor(BMAP_ANCHOR_BOTTOM_RIGHT);*/
      //第7步：绘制点  
      for (var i = 0; i < markerArr.length; i++) {
        markerArr[i].p0 = markerArr[i].point.split(",")[0];/*经度*/
        markerArr[i].p1 = markerArr[i].point.split(",")[1];/*纬度*/
        markerArr[i].label = new window.BMap.Label(markerArr[i].title, { offset: new window.BMap.Size(20, -10) });
        markerArr[i].marker = addMarker(new window.BMap.Point(markerArr[i].p0, markerArr[i].p1), i);
        markerArr[i].marker.index = i;
        markerArr[i].marker.addEventListener( 'click', function(){
          var $tr = $( '#tbody tr' ).eq( this.index );
          $tr.addClass( 'active' ).siblings().removeClass( 'active' );
          $( '#suggestId' ).val( this.index + 1 );
          showDetail(this); 
        });
        markerArr[i].marker.setLabel(markerArr[i].label);
        map.centerAndZoom(new window.BMap.Point(markerArr[i].p0, markerArr[i].p1),13);
        addInfoWindow(markerArr[i].marker, markerArr[i], i); 
      }
    }
    
    function jumpToMap( index ) {
      var 
        point = markerArr[index].point.split( ',' ),
        lng = point[0],
        lat = point[1]
      ;
      map.centerAndZoom( new BMap.Point( lng, lat ),13 );
    }
    
    function searchWatchPoint () {
      var value = $( '#suggestId' ).val();
      if ( !/\d+/.test(value) ) {
        alert( '请输入监测点id' );
        $( '#suggestId' ).focus();
        
      }else {
        jumpToMap( (value * 1 - 1) );
        var $tr = $( '#tbody tr' ).eq( value * 1 - 1);
        $tr.find( 'a' ).css( 'color', '#fff' );
        $tr.addClass( 'active' ).siblings().removeClass( 'active' );
      }
    }
    
    
    function setTableContent (markerArr) {
      var html = '';
      for ( var i = 0, len = markerArr.length; i < len; i++ ) {
        html += ' <tr> '
        + ' <td>'+ ( ++count ) +'</td> '
        + ' <td><a href="javascript:;">'+ markerArr[i]["title"] +'</a></td> '
        + ' <td>'+ markerArr[i]["point"] +'</td> '
        + ' <td>'+ markerArr[i]["address"] +'</td> '
        + ' <td>'+ markerArr[i]["tel"] +'</td> '
        + ' </tr>'
      }
      
      $( '#tbody' ).html( html );
      
      $( '#tbody' ).find( 'a' ).click( function () {
    	  
        $( this ).parents( 'tr' ).addClass( 'active' ).siblings().removeClass( 'active' );
       
        var index = $( this ).parents( 'tr' ).index();
        $( '#suggestId' ).val( index + 1 );
        jumpToMap( index );
      })
      
    }
    
    function showDetail (obj) {
      var 
        lng = obj.getPosition().lng,/*经度*/
        lat = obj.getPosition().lat;/*纬度*/
      ;
      map.centerAndZoom( new BMap.Point( lng,lat ), 13 );
    }

    function mergePoints (aAllPoints,aPoints){
      for(var i = 0, len = aPoints.length; i < len; i++) {
        aAllPoints.push(aPoints[i])
      }
      
      mergePoints.len = ++mergePoints.len || 1;
      if( mergePoints.len === markerArr.length ) {
        addOverlay( aAllPoints );
        mergePoints.len = 0;
      }
      
      return aAllPoints;
    }
    // 添加标注
    function addMarker(point, index) {
        var myIcon = new BMap.Icon("http://api.map.baidu.com/img/markers.png",
            new BMap.Size(23, 25), {
                offset: new BMap.Size(10, 25),
                imageOffset: new BMap.Size(0, 0 - index* 25)
            });
        var marker = new BMap.Marker(point, { icon: myIcon });
        /*
         * content: 在标注的周围模拟添加一组随机点
         * author: yuwanlin
         * 
         */
        map.addOverlay(marker);
        
        var w = new Worker( 'js/getRandomHeatPointWorker.js' );
        w.postMessage({
          point: point,
          swLng: map.getBounds().getSouthWest().lng,
          neLng: map.getBounds().getNorthEast().lng,
          swLat: map.getBounds().getSouthWest().lat,
          neLat: map.getBounds().getNorthEast().lat
        });
        w.onmessage = function ( ev ) {
          aPoints = ev.data;
          mergePoints( aAllPoints, aPoints );
          
          w.terminate();
        }
        
          
        return marker;
    } 
    
    //是否支持canvas，热力图目前只支持有canvas支持的浏览器
    function isSupportCanvas() {
        var elem = document.createElement('canvas');
        return !!(elem.getContext && elem.getContext('2d'));
    }
    
    /* 添加热力图覆盖物 */
    function addHeatmapOverlay(aAllPoints) {
      if(!isSupportCanvas()) {
        alert('热力图目前只支持有canvas支持的浏览器,您所使用的浏览器不能使用热力图功能~')
      }else {
        /* 初始化热力图 */
        heatmapOverlay = new BMapLib.HeatmapOverlay({"radius":20});
        map.addOverlay(heatmapOverlay);
        heatmapOverlay.setDataSet({data:aAllPoints,max:100});
        setInterval( function draw() {
          var w2 = new Worker( 'js/changePoints.js');
          w2.postMessage( aAllPoints );
          w2.onmessage = function ( ev ) {
            var aAllPoints = ev.data;
            
            map.addOverlay(heatmapOverlay);
            heatmapOverlay.setDataSet({data:aAllPoints,max:100});
            
            w2.terminate();
          }          
        }, 1000);
      }
    }
      
    
    /* 添加覆盖物 */
    function addOverlay(lng,lat) {
      /* 如果是一组数据，把它添加到热力图上 */
      if (Array.isArray(arguments[0])) {
        addHeatmapOverlay(aAllPoints);
      }else {/* 如果是单个点， 就把它设置为中心*/
        var point = new BMap.Point(lng,lat);            
        map.centerAndZoom(point,13); 
      }
    }
    
    /* 设置一组随机数据 */
    function getRandomHeatPoint(point) {
      map.centerAndZoom(point, 13);
      aPoints = [];
      var 
        bounds = map.getBounds(),//可视区域
        sw = bounds.getSouthWest(),//西南方向
        ne = bounds.getNorthEast(),//东北方向
        lngSpan = Math.abs(sw.lng - ne.lng),
        latSpan = Math.abs(sw.lat - ne.lat),
        pointObj = {}
      ;
      for (var i = 0; i < 50; i++) {
        pointObj = {
          lng : point.lng + lngSpan * ( Math.random() - 0.5 ) * 1,
          lat : point.lat + latSpan * ( Math.random() - 0.5 ) * 1,
          count : Math.ceil(Math.random() * 100)
        }
        aPoints.push(pointObj);
      }
      
    }

    // 添加信息窗口
    function addInfoWindow(marker, poi) {
        //pop弹窗标题
        var title = '<div style="font-weight:bold;color:#CE5521;font-size:14px">'+ poi.title + '</div>';
        //pop弹窗信息
        var html = [];
        html.push('<table cellspacing="0" style="table-layout:fixed;width:100%;font:12px arial,simsun,sans-serif"><tbody>');
        html.push('<tr>');
        html.push('<td style="vertical-align:top;line-height:16px;width:60px;white-space:nowrap;word-break:keep-all">检测车辆数:</td>');
        html.push('<td style="vertical-align:top;line-height:16px">' + poi.address + ' </td>');
        html.push('</tr>');
        html.push('<td style="vertical-align:top;line-height:16px;width:60px;white-space:nowrap;word-break:keep-all">超标车辆数:</td>');
        html.push('<td style="vertical-align:top;line-height:16px">' + poi.tel + ' </td>');
        html.push('</tr>');
        html.push('</tbody></table>');
        var infoWindow = new BMap.InfoWindow(html.join(""), { title: title, width: 200 });
        var openInfoWinFun = function () {
            marker.openInfoWindow(infoWindow);
        };
        marker.addEventListener("mouseover", openInfoWinFun);
        return openInfoWinFun;
    }

    //异步调用百度js
    function map_load() {
      //var load = document.createElement("script");
      // 实时路况
      //src="http://api.map.baidu.com/library/TrafficControl/1.4/src/TrafficControl_min.js";
      //load.src = "http://api.map.baidu.com/api?v=2.0&ak=E6YEqa4ZaeQk3qjjTTxUI4N2fnvMjscd&callback=map_init";
      // load.src = "http://api.map.baidu.com/api?v=1.4&callback=map_init";
      //document.body.appendChild(load);
      map_init();
    }
    
    return { 
      map_load: map_load,
      map_init: map_init,
      searchWatchPoint: searchWatchPoint
    }
  }())
  
  window.onload = watchModule.map_load;
  
</script>
</body>
</html>
