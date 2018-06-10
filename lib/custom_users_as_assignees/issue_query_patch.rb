module CustomUsersAsAssignees
  module IssueQueryPatch
    def self.included(base)      
      base.send :include, InstanceMethods
      base.class_eval do
        alias_method_chain :initialize_available_filters, :extra_filters
      end
    end
    
    module  InstanceMethods     
      def initialize_available_filters_with_extra_filters
        return @initialize_available_filters if @initialize_available_filters
        initialize_available_filters_without_extra_filters
 
        add_available_filter("just_assigned_to_id",
          :type => :list_optional, :values => lambda { assigned_to_values }
        )
        
        @initialize_available_filters

      end

      # call the original procedure for assigned_to_id_field
      def sql_for_just_assigned_to_id_field(field, operator, value)
        # "me" value substitution
        if "just_assigned_to_id".include?(field)
          if value.delete("me")
            if User.current.logged?
              value.push(User.current.id.to_s)
            else
              value.push("0")
            end
          end
        end
        '(' + sql_for_field("assigned_to_id", operator, value, Issue.table_name, "assigned_to_id") + ')'
      end

      # overwrite the procedure for assigned_to_id_field to query all custom users field
      def sql_for_assigned_to_id_field(field, operator, value)
        targets = value;
        value.each do |target|
          begin 
            targets += User.find(target).group_ids.map(&:to_s)
            targets.uniq!
          rescue
          end
        end

        int_values = targets.to_s.scan(/[+-]?\d+/).map(&:to_i).join(",")
        if int_values.present?
          subquery = "#{Issue.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } "
          subquery += "(SELECT #{Issue.table_name}.id FROM issues" + 
            " LEFT OUTER JOIN custom_values ON custom_values.customized_id = issues.id AND custom_values.customized_type = 'Issue'" + 
            " LEFT OUTER JOIN custom_fields ON custom_fields.id = custom_values.custom_field_id" + 
            " WHERE issues.assigned_to_id IN (#{int_values})" +
            " OR (custom_fields.field_format = 'user' AND custom_values.value IN (#{int_values}) ) )"
        end
      end      
      
    end # InstanceMethods
  end
end
