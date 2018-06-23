module CustomUsersAsAssignees
  module MailerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        class << self
          alias_method_chain :reminders, :custom_users
        end
      end
    end
  end

  module ClassMethods
    def reminders_with_custom_users(options={})
      days = options[:days] || 7
      project = options[:project] ? Project.find(options[:project]) : nil
      tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil
      target_version_id = options[:version] ? Version.named(options[:version]).pluck(:id) : nil
      if options[:version] && target_version_id.blank?
        raise ActiveRecord::RecordNotFound.new("Couldn't find Version with named #{options[:version]}")
      end
      user_ids = options[:users]

      scope = Issue.open.where("#{Issue.table_name}.assigned_to_id IS NOT NULL" +
        " AND #{Project.table_name}.status = #{Project::STATUS_ACTIVE}" +
        " AND #{Issue.table_name}.due_date <= ?", days.day.from_now.to_date
      )
      scope = scope.where(:project_id => project.id) if project
      scope = scope.where(:fixed_version_id => target_version_id) if target_version_id.present?
      scope = scope.where(:tracker_id => tracker.id) if tracker
      issues = scope.includes(:status, :assigned_to, :project, :tracker, :customized, customized: :custom_field)
      issues_by_assignee = issues.group_by(&:assigned_to)

      issues_by_assignee.keys.each do |assignee|
        if assignee.is_a?(Group)
          assignee.users.each do |user|
            issues_by_assignee[user] ||= []
            issues_by_assignee[user] += issues_by_assignee[assignee]
          end
        end
      end

      issues.each do |issue|
        assigneeid = issue["assigned_to_id"]
        issue.customized.each do |customizeduser|
          if customizeduser.custom_field["field_format"] == "user" && customizeduser.value && customizeduser.value != ""
            userid = customizeduser.value.to_i
            if userid != assigneeid
              user = User.find_by_id(userid)
              if user
                issues_by_assignee[user] ||= []
                issues_by_assignee[user].push(issue)
                issues_by_assignee[user].uniq!
              end
            end
          end
        end
      end

      issues_by_assignee.each do |assignee, issues|
        if assignee.is_a?(User) && assignee.active? && issues.present?
          if user_ids.empty? || user_ids.include?(assignee.id.to_s)
            visible_issues = issues.select {|i| i.visible?(assignee)}
            reminder(assignee, visible_issues, days).deliver if visible_issues.present?
          end
        end
      end
    end
  end
end
