
ready = ->
  $('#load-account-settings-button').on 'click', (event) -> loadAccountSettings(event)
  $('#load-mooc-provider-settings-button').on 'click', (event) -> loadMoocProviderSettings(event)
  return

$(document).ready(ready)

loadAccountSettings = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  url = "/users/#{user_id}/account_settings.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      $("div.settings-container").html(data.partial)
      window.history.pushState({id: 'set_account_subsite'}, '', 'settings?subsite=account');
  event.preventDefault()

loadMoocProviderSettings = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  url = "/users/#{user_id}/mooc_provider_settings.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      $("div.settings-container").html(data.partial)
      window.history.pushState({id: 'set_mooc_provider_subsite'}, '', 'settings?subsite=mooc_provider');
  event.preventDefault()

synchronizeNaiveUserMoocProviderConnection = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  mooc_provider = button.data('mooc_provider')
  email = $("#input-email-#{mooc_provider}").val()
  password = $("#input-password-#{mooc_provider}").val()
  url = "/users/#{user_id}/set_mooc_provider_connection.json"
  $.ajax
    url: url
    method: 'GET'
    data:{email:email, password: password, mooc_provider:mooc_provider}
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      if data.status == true
        $("div.settings-container").html(data.partial)
      else
        $("#div-error-#{mooc_provider}").text("Error!")
  event.preventDefault()

revokeNaiveUserMoocProviderConnection = (event) ->
  button = $(event.target)
  user_id = button.data('user_id')
  mooc_provider = button.data('mooc_provider')
  url = "/users/#{user_id}/revoke_mooc_provider_connection.json"
  $.ajax
    url: url
    method: 'GET'
    data:{mooc_provider:mooc_provider}
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_synchronize')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      if data.status == true
        $("div.settings-container").html(data.partial)
      else
        $("#div-error-#{mooc_provider}").text("Error!")
  event.preventDefault()

@bindClickEvents = () ->
  $('button[id="sync-naive-user-mooc_provider-connection-button"]').on 'click', (event) ->
    synchronizeNaiveUserMoocProviderConnection(event)
  $('button[id="revoke-naive-user-mooc_provider-connection-button"]').on 'click', (event) ->
    revokeNaiveUserMoocProviderConnection(event)