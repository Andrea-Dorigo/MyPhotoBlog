import Rails from "@rails/ujs";
window.Rails = Rails;

window.addEventListener('popstate', function(event) {
    window.location.replace("/show_photo_gallery/" + window.location.search);
}, false);

// window.onload = function(){
//     document.getElementById("refresh_icon").onclick = function(){
//         this.classList.add("rotating");
//     };
// };
