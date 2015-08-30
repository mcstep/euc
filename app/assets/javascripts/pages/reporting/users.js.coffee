$ ->
  $('.reportingform #partners').multiselect
    enableFiltering: true
    enableCaseInsensitiveFiltering: true
    filterBehavior: 'both'
    filterPlaceholder: 'Search...'
    buttonClass: 'partners btn btn-default'
    includeSelectAllOption: true
    selectAllNumber: true
    buttonWidth: '100%'
    nonSelectedText: 'All Partners'
    numberDisplayed: 10

  $('.reportingform #region').multiselect
    enableFiltering: true
    enableCaseInsensitiveFiltering: true
    filterBehavior: 'both'
    filterPlaceholder: 'Search...'
    buttonClass: 'partners btn btn-default'
    includeSelectAllOption: true
    selectAllNumber: true
    buttonWidth: '100%'
    nonSelectedText: 'All Regions'
    numberDisplayed: 10

  $('.reportingform #partners-clearall').on 'click', (event) ->
    event.preventDefault()

    $('.reportingform #partners').val('')
    $('.reportingform #partners').multiselect('refresh')

    $('.reportingform #region').val('')
    $('.reportingform #region').multiselect('refresh')

    $('.reportingform input').val('')

    return false