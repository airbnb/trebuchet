# Represents the internal, global and thread-unsafe state of Trebuchet
Trebuchet::State = Struct.new(
  :visitor_id, :current, :current_block,
  :logs, :admin_view, :admin_edit, :time_zone,
  :author
)
