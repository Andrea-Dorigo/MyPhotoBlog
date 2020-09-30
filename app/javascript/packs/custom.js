// $.get( "/", function(data) {
//   alert("Vegetables are good for you!");
// });
import Rails from "@rails/ujs";
window.Rails = Rails;
console.log("loaded custom.js");

// Rails.ajax({
//   url: "/test",
//   type: "POST",
//   data: "",
//   success: function(data) {
//     console.log("success")
//   }
// })
Rails.ajax({
  url: "/show_photos_js",
  type: "get",
  data: "",
  success: function(data) {
    console.log("here i am")
  },
})
// $('.random_word').bind('ajax:success', function() {
//      console.log("i'm in")
// });
// document.getElementById("id2").onclick = function() {
//   console.log(this.getAttribute("data-test"));
// }
// console.log(document.getElementsByClassName("selected"));
