// Adapted from https://github.com/projectblacklight/blacklight/blob/master/app/javascript/blacklight/modal.js
//= require bootstrap-sprockets

Reserves = {};

if (Reserves.modal === undefined) {
  Reserves.modal = {};
}

Reserves.modal.modalSelector = '#modal';
Reserves.modal.containerSelector    = '[data-modal~=container]';
Reserves.modal.modalCloseSelector   = '[data-modal~=close]';

Reserves.modal.modalAjaxClickLink = function(e) {
  e.preventDefault();

  $.ajax({
    url: $(this).attr('href')
  })
  .fail(Reserves.modal.onFailure)
  .done(Reserves.modal.receiveAjax)
}

// Called on fatal failure of ajax load, function returns content
// to show to user in modal.  Right now called only for extreme
// network errors.
Reserves.modal.onFailure = function(data) {
  var contents =  '<div class="modal-header">' +
            '<div class="modal-title">Network Error</div>' +
            '<button type="button" class="Reserves-modal-close close" data-dismiss="modal" aria-label="Close">' +
            '  <span aria-hidden="true">&times;</span>' +
            '</button>';
  $(Reserves.modal.modalSelector).find('.modal-content').html(contents);
  $(Reserves.modal.modalSelector).modal('show');
}

Reserves.modal.receiveAjax = function (contents) {
  // does it have a data- selector for container?
  // important we don't execute script tags, we shouldn't.
  // code modelled off of JQuery ajax.load. https://github.com/jquery/jquery/blob/master/src/ajax/load.js?source=c#L62
  var container =  $('<div>').
    append( jQuery.parseHTML(contents) ).find( Reserves.modal.containerSelector ).first();
  if (container.length !== 0) {
    contents = container.html();
  }

  $(Reserves.modal.modalSelector).find('.modal-content').html(contents);

  // send custom event with the modal dialog div as the target
  var e    = $.Event('loaded.Reserves.Reserves-modal')
  $(Reserves.modal.modalSelector).trigger(e);
  // if they did preventDefault, don't show the dialog
  if (e.isDefaultPrevented()) return;

  $(Reserves.modal.modalSelector).modal('show');
};

$(document).ready(function(){
  $('body').on('click', '[data-modal~=trigger]', Reserves.modal.modalAjaxClickLink);
});
