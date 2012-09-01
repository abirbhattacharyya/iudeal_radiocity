
var mobileWidthMax = 600;  // switch between mobile & full versions

var windowWidth = null;
var windowHeight = null;

$(document).ready(function() {
    layoutManager();
});

$(window).bind('resize', function() {
    layoutManager()
});

function layoutManager() {
    redefineWindowSize();  // first: initial
    switchView();
    redefineWindowSize();  // second: after view switching
    adjustComponents();
}

function redefineWindowSize() {
    windowWidth = $(window).width();
    windowHeight = $(window).height();
}

function switchView() {
    if(windowWidth > mobileWidthMax) {
        // full version
        $('body').removeClass('mobile');
        $('body').addClass('full');
    } else {
        // mobile version
        $('body').removeClass('full');
        $('body').addClass('mobile');
    }
}

function adjustComponents() {
    // full version
    $('.full .page-layout').css('height', 'auto');

    // mobile version
    $('.mobile .page-layout').css('height', windowHeight-1+'px');
}

