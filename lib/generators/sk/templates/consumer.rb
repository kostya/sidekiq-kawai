class Sk<%= class_name %> < SkQueue

  # insert event like: Sk<%= class_name %>.some_event("haha")

  def some_event(h)
    logger.info "async called event with #{h.inspect}"
  end

end
