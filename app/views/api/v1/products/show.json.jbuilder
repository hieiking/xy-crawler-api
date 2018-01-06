json.product do
  json.(@product, :id, :name, :keywords,  :lower_p, :upper_p, :filter, :alarm_p, :record_ids, :except_ids, :created_at, :updated_at)
end