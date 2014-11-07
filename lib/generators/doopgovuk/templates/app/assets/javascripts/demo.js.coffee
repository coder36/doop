$( () ->
  history.pushState("back", null, null);
  if typeof history.pushState == "function"
    history.pushState("back", null, null);
    window.onpopstate = (evt) ->
      history.pushState('back', null, null);
      $( "#back_a_page" ).val( "pressed" )
      $( "#back_a_page" ).click()

  $('#doop_debug').dialog( { autoOpen: false, height: 400, width: 400, position: { my: 'right top', at: 'right top' } })
  $("body").keydown (e) ->
    if e.ctrlKey && e.keyCode == 89
      $('#doop_debug').dialog( "open")
    
  bind_ga_events()  
)
