json.array!(@reg_codes) do |reg_code|
  json.extract! reg_code, :id, :code, :valid_from, :valid_to, :status, :registrations, :account_type, :account_validity
  json.url reg_code_url(reg_code, format: :json)
end
