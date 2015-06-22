$ ->
  setRemoveAvatar = (remove) ->
    document.getElementById('edit-profile-remove-avatar').checked = remove
    return

  toggleEditProfileMode = ->
    $editProfileModal.toggleClass 'webcam-active'
    return

  setWebcamShotDisabled = (disabled) ->
    $webcamShot.prop 'disabled', disabled
    return

  disableWebcam = ->
    if Webcam.container
      Webcam.reset()
    return

  $editProfileForm = $('#edit-profile-form')

  if $editProfileForm.length
    # we manually append to file input to assert that it's value is unset
    $avatarFile = $('<input class="hidden" type="file"/>').appendTo($editProfileForm)
    $editProfileModal = $('#edit-profile-modal')
    $generalAvatarButtons = $('#edit-profile-left-buttons').children()
    $generalTakePhoto = $generalAvatarButtons.eq(0)
    $generalUploadPhoto = $generalAvatarButtons.eq(1)
    $generalRemovePhoto = $generalAvatarButtons.eq(2)
    $editProfileWebcam = $('#edit-profile-webcam')
    $webcamShot = $('#edit-profile-webcam-shot')
    $editProfileWebcamContainer = $('div', $editProfileWebcam)
    $editProfileWebcamSave = $('.btn-success', $editProfileWebcam)
    $editProfileWebcamCancel = $('.btn-default', $editProfileWebcam)
    $avatarDataField = null
    setRemoveAvatar false
    $editProfileModal.on 'show.bs.modal', ->
      $editProfileModal.removeClass 'webcam-active'
      return
    $editProfileModal.on 'hide.bs.modal', disableWebcam
    $editProfileForm.on 'submit', ->
      $editProfileModal.modal 'hide'
      return
    $avatarFile.on 'change', ->
      if @value
        setRemoveAvatar false
        $avatarFile.attr 'name', 'user[avatar]'
        $editProfileForm.submit()
      return
    $generalTakePhoto.on 'click', ->
      toggleEditProfileMode()
      Webcam.on 'live', ->
        $webcamShot.prop 'disabled', false

        ###
        # If the user had to click on a button within the browser UI
        # to allow the access to the camera, the focus on the
        # browser content might be lost. This means that key events
        # like the escape key which closes the modal won't be triggered anymore.
        ###

        $webcamShot.focus()
        return
      Webcam.on 'error', (err) ->
        disableWebcam()
        $editProfileWebcamContainer.css('display', 'table').html '<div>' + err + '</div>'
        $webcamShot.prop 'disabled', true
        return
      Webcam.set
        width: 480
        height: 360
        crop_width: 480
        crop_height: 480
        dest_width: 640
        dest_height: 480
        flip_horiz: true
      Webcam.attach $editProfileWebcamContainer[0]
      return
    $generalUploadPhoto.on 'click', ->
      $avatarFile.click()
      return
    $generalRemovePhoto.on 'click', ->
      setRemoveAvatar true
      $avatarFile.removeAttr 'name'
      $editProfileForm.submit()
      return
    $webcamShot.on 'click', ->
      Webcam.snap (data_uri) ->
        if !$avatarDataField
          $avatarDataField = $('<textarea class="hidden" name="user[avatar_data_uri]"></textarea>').appendTo($editProfileForm)
        $avatarDataField.val data_uri
        $editProfileWebcamSave.prop 'disabled', false
        return
      Webcam.freeze()
      return
    $editProfileWebcamCancel.on 'click', ->
      disableWebcam()
      toggleEditProfileMode()
      return
