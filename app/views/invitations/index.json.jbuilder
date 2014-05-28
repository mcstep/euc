json.array!(@invitations) do |invitation|
  json.extract! invitation, :id, :sender_id, :recipient_email, :token, :recipient_username, :recipient_firstname, :recipient_lastname, :recipient_title, :recipient_company
  json.url invitation_url(invitation, format: :json)
end
