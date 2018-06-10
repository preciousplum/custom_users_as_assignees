module CustomUsersAsAssignees
  module UserPatch
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def notify_custom_user?(object, custom_users_current, custom_users_changed)
        if %w(selected only_my_events only_assigned).include?(mail_notification)
          object.is_a?(Issue) &&
              (custom_users_changed.include?(self) || (custom_users_changed == [] && custom_users_current.include?(self)))
        end
      end
    end
  end
end
