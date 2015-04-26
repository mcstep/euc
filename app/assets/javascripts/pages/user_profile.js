(function () {
	function page_scripts() {
		var $editProfileForm = $('#edit-profile-form');

		if ($editProfileForm.length) {
			function setRemoveAvatar(remove) {
				document.getElementById('edit-profile-remove-avatar').checked = remove;
			}

			// we manually append to file input to assert that it's value is unset
			var $avatarFile = $('<input class="hidden" type="file"/>').appendTo($editProfileForm);

			var $editProfileModal = $('#edit-profile-modal');
			var $generalAvatarButtons = $('#edit-profile-left-buttons').children();
			var $generalTakePhoto = $generalAvatarButtons.eq(0);
			var $generalUploadPhoto = $generalAvatarButtons.eq(1);
			var $generalRemovePhoto = $generalAvatarButtons.eq(2);

			setRemoveAvatar(false);

			$avatarFile.on('change', function () {
				if (this.value) {
					setRemoveAvatar(false);
					$avatarFile.attr('name', 'user[avatar]');
					$editProfileForm.submit();
				}
			});

			$generalUploadPhoto.on('click', function () {
				$avatarFile.click();
			});

			$generalRemovePhoto.on('click', function () {
				setRemoveAvatar(true);
				$avatarFile.removeAttr('name');
				$editProfileForm.submit();
			});

			$editProfileForm.on('submit', function () {
				$editProfileModal.modal('hide');
			});

			$editProfileModal.on('show.bs.modal', function () {
				$editProfileModal.removeClass('webcam-active');
			});

			var editProfileWebcamCanvas = document.createElement('canvas');

			if (typeof ImageData !== 'function' || !editProfileWebcamCanvas || !editProfileWebcamCanvas.toDataURL) {
				$generalTakePhoto.prop('disabled', true);
			} else {
				function toggleEditProfileMode() {
					$editProfileModal.toggleClass('webcam-active');
				}

				function setWebcamShotDisabled(disabled) {
					$webcamShot.prop('disabled', disabled);
				}

				var $editProfileWebcam = $('#edit-profile-webcam');
				var $webcamShot = $('#edit-profile-webcam-shot');
				var $editProfileWebcamContainer = $('div', $editProfileWebcam);
				var $editProfileWebcamSave = $('.btn-success', $editProfileWebcam);
				var $editProfileWebcamCancel = $('.btn-default', $editProfileWebcam);
				var $avatarDataField = null;
				var width = $editProfileWebcamContainer.width();
				var height = $editProfileWebcamContainer.height();
				var ctx = editProfileWebcamCanvas.getContext('2d');
				var image = ctx.getImageData(0, 0, width, height);
				var initialized = false;

				editProfileWebcamCanvas.setAttribute('width', width);
				editProfileWebcamCanvas.setAttribute('height', height);

				$editProfileWebcamCancel.on('click', function () {
					toggleEditProfileMode();
				});

				$generalTakePhoto.on('click', function () {
					toggleEditProfileMode();

					if (!initialized) {
						initialized = true;

						$editProfileWebcamContainer.webcam({
							swffile: '/assets/sAS3Cam.swf',

							previewWidth: width,
							previewHeight: height,

							resolutionWidth: width,
							resolutionHeight: height,

							StageScaleMode: 'noBorder',

							mode: 'callback',

							debug: function (type, string) {
								console.log(type + ": " + string);

								if (type === 'error') {
									$editProfileWebcamContainer.html('<div>' + string + '</div>');
								}
							},

							noCameraFound: function () {
								this.debug('error', 'Camera is not available.');
							},

							swfApiFail: function (e) {
								this.debug('error', 'Internal camera plugin error.');
							},

							cameraDisabled: function () {
								this.debug('error', 'Please allow access to your camera.');
								$webcamShot.prop('disabled', true);
							},

							cameraEnabled:  function () {
								var self = this;

								if (self.isCameraEnabled) {
									return;
								}

								self.isCameraEnabled = true;
								self.debug('notice', 'Camera enabled');
								self.setCamera('0');

								$webcamShot.prop('disabled', false).on('click', function () {
									var result = self.save();

									if (result) {
										if (!$avatarDataField) {
											$avatarDataField = $('<textarea class="hidden" name="user[avatar_data_uri]"></textarea>').appendTo($editProfileForm);
										}

										$avatarDataField.val('data:image/jpeg;base64,' + result);
										$editProfileWebcamSave.prop('disabled', false);

										self.setCamera('0');
									} else {
										self.debug('error', 'Broken camera');
									}
								});
							}
						});
					}
				});
			}
		}
	}

	$(page_scripts);
	$(document).on('page:load', page_scripts);
})();
