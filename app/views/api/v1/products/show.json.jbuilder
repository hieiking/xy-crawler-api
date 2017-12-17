json.user do
  json.(@product, :id, :email, :name,  :activated, :admin, :created_at, :updated_at)
end