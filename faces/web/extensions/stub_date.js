//if (!window.__RealDate) {
console.warn('Stubbing date.');

window.__RealDate = window.Date;
window.Date = function () {
   var args, date;

   //console.log('Using stubbed date.');

   args = Array.prototype.slice.call(arguments);

   date = eval('new __RealDate(' + args.join(',') + ')');

   if (arguments.length == 0) {
      date.setFullYear(date.getFullYear(), 5, 7); // June 7
   }

   return date;
};
//}

window.Date.parse = window.__RealDate.parse;