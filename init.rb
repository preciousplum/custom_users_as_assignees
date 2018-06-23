require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'project'
  require_dependency 'principal'
  require_dependency 'user'
  require_dependency 'issue'
  require_dependency 'issue_query'
  require_dependency 'mailer'

  unless Issue.included_modules.include? CustomUsersAsAssignees::IssuePatch
    Issue.send :include, CustomUsersAsAssignees::IssuePatch
  end
  unless User.included_modules.include? CustomUsersAsAssignees::UserPatch
    User.send :include, CustomUsersAsAssignees::UserPatch
  end
  unless IssueQuery.included_modules.include? CustomUsersAsAssignees::IssueQueryPatch
    IssueQuery.send :include, CustomUsersAsAssignees::IssueQueryPatch
  end
  unless Mailer.included_modules.include? CustomUsersAsAssignees::MailerPatch
    Mailer.send :include, CustomUsersAsAssignees::MailerPatch
  end

end

Redmine::Plugin.register :custom_users_as_assignees do
  name 'Expand Custom Users as Assignees plugin'
  author 'preciousplum'
  description 'Redmine plugin for adding assignee functionality includes default query and reminder to custom users'
  version '0.0.3'
  url 'https://github.com/preciousplum/custom_users_as_assignees'
  author_url 'https://github.com/preciousplum/'
end
