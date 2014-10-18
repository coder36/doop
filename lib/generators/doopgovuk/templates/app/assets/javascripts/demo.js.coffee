$( () ->
  history.pushState("back", null, null);
  if typeof history.pushState == "function"
    history.pushState("back", null, null);
    window.onpopstate = (evt) ->
      history.pushState('back', null, null);
      $( "#back_a_page" ).val( "pressed" )
      $( "#back_a_page" ).click()
)
