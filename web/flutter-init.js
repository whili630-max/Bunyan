window.addEventListener('load', function() {
  // تهيئة _flutter إذا لم يكن موجودًا
  if (typeof _flutter === 'undefined') {
    window._flutter = {
      loader: {
        loadEntrypoint: function(config) {
          // تحميل main.dart.js
          var scriptTag = document.createElement('script');
          scriptTag.src = 'main.dart.js';
          document.body.appendChild(scriptTag);
        }
      }
    };
  }
});
