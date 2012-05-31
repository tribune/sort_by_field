module SortByField
  DESCENDING = 'des'.freeze

  # Sort by a particular field of the elements of the array. All the elements should respond to the method indicated by field.
  # By default, strings will be sorted case insensitive and nil will come before all other elements. This can be changed
  # by specifying :case_sensitive => true in the last argument. The sort order can be reversed by specifying " desc" after any
  # of the fields. Nil values will be sorted last by default, but they can be put last by specifying :nil_last => true.
  def sort_by_field (*fields)
    if fields.last.is_a?(Hash)
      options = fields.last
      fields = fields[0, fields.size - 1]
    else
      options = {}
    end

    fields = fields.collect do |f|
      if f.is_a?(String) and f.include?('.')
        f.split('.')
      else
        f
      end
    end

    fields, order = extract_field_order(fields)
    field_cache = {}
    sort {|a, b| field_compare(a, b, options[:case_sensitive], options[:nil_last], order, fields, field_cache)}
  end

  private

  def field_compare (a, b, case_sensitive, nil_last, order, fields, field_cache)
    field = fields.first

    a_val = sort_field_value(a, field, field_cache)
    b_val = sort_field_value(b, field, field_cache)

    if a_val.nil? and b_val.nil?
      return 0
    elsif b_val.nil?
      retval = (nil_last ? -1 : 1)
    elsif a_val.nil?
      retval = (nil_last ? 1 : -1)
    else
      if a_val.is_a?(String) and b_val.is_a?(String) and !case_sensitive
        retval = a_val.casecmp(b_val)
      else
        retval = a_val <=> b_val
      end
    end

    retval *= -1 if order == DESCENDING

    if retval == 0 and fields.size > 1
      fields, order = extract_field_order(fields[1, fields.length])
      return field_compare(a, b, case_sensitive, nil_last, order, fields, field_cache)
    else
      return retval
    end
  end

  def sort_field_value (object, field, field_cache)
    return nil if object.nil?

    object_cache = field_cache[object]
    unless object_cache
      object_cache = {}
      field_cache[object] = object_cache
    end

    if object_cache.include?(field)
      return object_cache[field]
    else
      value = nil
      if object
        if field.is_a?(Array)
          value = field.inject(object){|obj, f| sort_field_value(obj, f, field_cache)}
        else
          value = object.send(field)
          object_cache[field] = value
        end
      end
      return value
    end
  end

  def extract_field_order (field_list)
    field = field_list.is_a?(Array) ? field_list.first : field_list
    field_with_order = field.is_a?(Array) ? field.last : field
    field_without_order, order = field_with_order.split(' ', 2) if field_with_order.is_a?(String)
    if order
      order = order[0, 3].downcase
      if field.is_a?(Array)
        field = field[0, field.size - 1] << field_without_order
      else
        field = field_without_order
      end

      if field_list.is_a?(Array)
        field_list[0] = field
      else
        field_list = field
      end
    end
    return [field_list, order]
  end
end

Enumerable.extend SortByField
Array.send(:include, SortByField)
