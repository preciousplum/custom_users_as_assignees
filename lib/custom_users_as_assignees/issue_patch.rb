module CustomUsersAsAssignees
  module IssuePatch

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :has_many, :customized, :class_name => 'CustomValue', :foreign_key => 'customized_id'
      base.class_eval do
        alias_method_chain :notified_users, :custom_users
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
        User.find(custom_user_ids)
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
          User.find(custom_user_changed_ids)
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
    end
  end
end
