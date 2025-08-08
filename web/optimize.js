// Simple performance optimization script
document.addEventListener('DOMContentLoaded', function() {
  // Defer non-critical resources
  setTimeout(function() {
    // Load fonts and other non-critical resources here
    const fontLink = document.createElement('link');
    fontLink.rel = 'stylesheet';
    fontLink.href = 'https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700&display=swap';
    document.head.appendChild(fontLink);
  }, 1000);
});

// Add to page performance
window.addEventListener('load', function() {
  // Mark when app becomes interactive
  if ('performance' in window && 'mark' in performance) {
    performance.mark('app-interactive');
  }
});
