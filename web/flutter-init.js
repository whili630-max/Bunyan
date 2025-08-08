// تعريف _flutter قبل استخدامه في الصفحة
window._flutter = window._flutter || {};
window._flutter.loader = window._flutter.loader || {};
window._flutter.loader.loadEntrypoint = window._flutter.loader.loadEntrypoint || function(config) {
  // تحميل main.dart.js بشكل صريح
  var scriptTag = document.createElement('script');
  scriptTag.src = 'main.dart.js';
  scriptTag.type = 'application/javascript';
  document.body.appendChild(scriptTag);
};
