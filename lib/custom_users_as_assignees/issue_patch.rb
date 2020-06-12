module CustomUsersAsAssignees
  module IssuePatch

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :has_many, :customized, :class_name => 'CustomValue', :foreign_key => 'customized_id'
      base.extend ClassMethods
      base.class_eval do
        alias_method :notified_users_without_custom_users, :notified_users
        alias_method :notified_users, :notified_users_with_custom_users
        alias_method :visible_without_custom_users?, :visible?
        alias_method :visible?, :visible_with_custom_users?
        class << self
          alias_method :visible_condition_without_custom_users, :visible_condition
          alias_method :visible_condition, :visible_condition_with_custom_users
        end
      end
    end

    module ClassMethods
      def visible_condition_with_custom_users(user, options={})

        user_ids = []
        if user.logged?
          user_ids = [user.id] + user.groups.map(&:id).compact
        end

        prj_clause = nil
        if !options.nil? && !options[:project].nil?
          prj_clause = " #{Project.table_name}.id = #{options[:project].id}"
          if options[:with_subprojects]
            prj_clause << " OR (#{Project.table_name}.lft > #{options[:project].lft} AND #{Project.table_name}.rgt < #{options[:project].rgt})"
          end
        end

        issues_clause = ""
        unless user_ids.empty?
          issues_clause << "#{Issue.table_name}.id in ("
          issues_clause << "SELECT cv.customized_id"
          issues_clause << " FROM #{CustomField.table_name} AS cf"
          issues_clause << " INNER JOIN #{CustomValue.table_name} AS cv"
          issues_clause << " ON cv.custom_field_id = cf.id"
          issues_clause << " AND cv.customized_type = 'Issue'"
          issues_clause << " AND cv.value in (#{user_ids.map{ |e| "'#{e}'" }.join(',')})"
          issues_clause << " WHERE cf.field_format = 'user'"
          issues_clause << ")"
          issues_clause << " AND (#{prj_clause})" if prj_clause
        end

        "( #{visible_condition_without_custom_users(user, options)} OR (#{issues_clause})) "
      end
    end

    module InstanceMethods
      # find users selected in custom fields with type 'user'
      def custom_users
        custom_user_values = custom_field_values.select do |v|
          v.custom_field.field_format == "user"
        end
        custom_user_ids = custom_user_values.map(&:value).flatten
        custom_user_ids.reject! { |id| id.blank? }
#        User.find(custom_user_ids)
#        Principal.find(custom_user_ids)
        return users_from_ids(custom_user_ids)
      end

      def users_from_ids(ids)
        users = []
        ids.each do |id|
          user = User.find_by_id(id)
          if user
            users << user
            next
          end
          group = Group.find_by_id(id)
          if group
            users += users_from_ids(group.user_ids)
            next
          end
        end
        return users
      end

      # added or removed users selected in custom fields with type 'user'
      def custom_users_added_or_removed
        if last_journal_id && (journal = journals.find(last_journal_id))
          custom_user_added_ids = []
          custom_user_removed_ids = []
          journal.details.each do |det|
            if det.property == 'cf'
              custom_field_id = det.prop_key
              if CustomField.find_by_id(custom_field_id).field_format == 'user'
                custom_user_added_ids <<  det.value if det.value.present?
                custom_user_removed_ids <<  det.old_value if det.old_value.present?
              end
            end
          end
          custom_user_added_ids.uniq!
          custom_user_removed_ids.uniq!
          custom_user_changed_ids = (custom_user_added_ids + custom_user_removed_ids).uniq
          return users_from_ids(custom_user_changed_ids)
        else
          []
        end
      end

      # add 'custom users' to notified_users
      def notified_users_with_custom_users
        notified = notified_users_without_custom_users

        custom_users_current = custom_users
        custom_users_changed = custom_users_added_or_removed

        notified_custom_users = (custom_users_current + custom_users_changed).select do |u|
          u.active? && u.notify_custom_user?(self, custom_users_current, custom_users_changed) && visible?(u)
        end
        notified += notified_custom_users
        notified.uniq
      end

      def visible_with_custom_users?(usr=nil)
        visible = visible_without_custom_users?(usr)
        return true if visible

        u = usr
        u ||= User.current
        if u.logged?
          custom_users().each do |custom_user|
            return true if custom_user.id == u.id
          end
        end
        return visible
      end
    end
  end
end
