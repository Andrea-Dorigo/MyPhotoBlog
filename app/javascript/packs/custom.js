import Rails from "@rails/ujs";
window.Rails = Rails;


// console.log("heyya");
window.addEventListener('popstate', function(event) {
    window.location.replace("/" + window.location.search);
}, false);

// window.onload = function(){
//     document.getElementById("refresh_icon").onclick = function(){
//         this.classList.add("rotating");
//     };
// };
