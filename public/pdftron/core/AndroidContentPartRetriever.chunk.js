/** Notice * This file contains works from many authors under various (but compatible) licenses. Please see core.txt for more information. **/
(function(){(window.wpCoreControlsBundle=window.wpCoreControlsBundle||[]).push([[3],{376:function(Ba,ya,z){z.r(ya);var qa=z(1),ka=z(216);Ba=z(372);z=z(339);var la=window,ha=function(da){function y(r,h){var a=da.call(this,r,h)||this;a.url=r;a.range=h;a.request=new XMLHttpRequest;a.request.open("GET",a.url,!0);la.Uint8Array&&(a.request.responseType="arraybuffer");a.request.setRequestHeader("X-Requested-With","XMLHttpRequest");a.status=ka.a.NOT_STARTED;return a}Object(qa.c)(y,da);return y}(Ba.ByteRangeRequest);
Ba=function(da){function y(r,h,a,b){r=da.call(this,r,h,a,b)||this;r.Lv=ha;return r}Object(qa.c)(y,da);y.prototype.Tt=function(r,h){return r+"/bytes="+h.start+","+(h.stop?h.stop:"")};return y}(Ba["default"]);Object(z.a)(Ba);Object(z.b)(Ba);ya["default"]=Ba}}]);}).call(this || window)
