$ ->
  $('#delivery_body').each ->
    CodeMirror.fromTextArea this,
      lineNumbers: true,
      mode: "htmlmixed"