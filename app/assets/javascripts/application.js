//= require jquery
//= require jquery.cookie
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.en-GB.js
//= require bootstrap-hover-dropdown
//= require webcamjs/webcam
//= require webshims/polyfiller
//= require_tree .
$.webshims.setOptions('basePath', '/assets/webshims/shims/')
$.webshims.polyfill()