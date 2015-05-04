(function () {
	function page_scripts() {
		var $editProfileForm = $('#edit-profile-form');

		if ($editProfileForm.length) {
			function setRemoveAvatar(remove) {
				document.getElementById('edit-profile-remove-avatar').checked = remove;
			}

			function toggleEditProfileMode() {
				$editProfileModal.toggleClass('webcam-active');
			}

			function setWebcamShotDisabled(disabled) {
				$webcamShot.prop('disabled', disabled);
			}

			function disableWebcam() {
				if (Webcam.container) {
					Webcam.reset();
				}
			}

			// we manually append to file input to assert that it's value is unset
			var $avatarFile = $('<input class="hidden" type="file"/>').appendTo($editProfileForm);

			var $editProfileModal = $('#edit-profile-modal');
			var $generalAvatarButtons = $('#edit-profile-left-buttons').children();
			var $generalTakePhoto = $generalAvatarButtons.eq(0);
			var $generalUploadPhoto = $generalAvatarButtons.eq(1);
			var $generalRemovePhoto = $generalAvatarButtons.eq(2);

			var $editProfileWebcam = $('#edit-profile-webcam');
			var $webcamShot = $('#edit-profile-webcam-shot');
			var $editProfileWebcamContainer = $('div', $editProfileWebcam);
			var $editProfileWebcamSave = $('.btn-success', $editProfileWebcam);
			var $editProfileWebcamCancel = $('.btn-default', $editProfileWebcam);
			var $avatarDataField = null;

			setRemoveAvatar(false);

			$editProfileModal.on('show.bs.modal', function () {
				$editProfileModal.removeClass('webcam-active');
			});

			$editProfileModal.on('hide.bs.modal', disableWebcam);

			$editProfileForm.on('submit', function () {
				$editProfileModal.modal('hide');
			});

			$avatarFile.on('change', function () {
				if (this.value) {
					setRemoveAvatar(false);
					$avatarFile.attr('name', 'user[avatar]');
					$editProfileForm.submit();
				}
			});

			$generalTakePhoto.on('click', function () {
				toggleEditProfileMode();

				Webcam.on('live', function () {
					$webcamShot.prop('disabled', false);
				});

				Webcam.on('error', function (err) {
					disableWebcam();
					$editProfileWebcamContainer.css('display', 'table').html('<div>' + err + '</div>');
					$webcamShot.prop('disabled', true);
				});

				Webcam.set({
					width: 480,
					height: 360,
					crop_width: 480,
					crop_height: 480,
					dest_width: 640,
					dest_height: 480,
					flip_horiz: true,
				});

				Webcam.attach($editProfileWebcamContainer[0]);
			});

			$generalUploadPhoto.on('click', function () {
				$avatarFile.click();
			});

			$generalRemovePhoto.on('click', function () {
				setRemoveAvatar(true);
				$avatarFile.removeAttr('name');
				$editProfileForm.submit();
			});

			$webcamShot.on('click', function () {
				Webcam.snap(function (data_uri) {
					if (!$avatarDataField) {
						$avatarDataField = $('<textarea class="hidden" name="user[avatar_data_uri]"></textarea>').appendTo($editProfileForm);
					}

					$avatarDataField.val(data_uri);
					$editProfileWebcamSave.prop('disabled', false);
				});
				Webcam.freeze();
			});

			$editProfileWebcamCancel.on('click', function () {
				disableWebcam();
				toggleEditProfileMode();
			});
		}
	}

	$(page_scripts);
	$(document).on('page:load', page_scripts);
})();
