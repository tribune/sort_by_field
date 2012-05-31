require "#{File.dirname(__FILE__)}/lib/sort_by_field"
Array.send(:include, SortByField) unless Array.include?(SortByField)
ActiveRecord::NamedScope::Scope.send(:include, SortByField) unless ActiveRecord::NamedScope::Scope.include?(SortByField)
