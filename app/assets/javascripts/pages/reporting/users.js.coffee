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