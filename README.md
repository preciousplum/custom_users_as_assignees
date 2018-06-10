# Expand Custom Users as Assignees plugin
Redmine plugin for adding assignee functionality includes default query and reminder to custom users

This plugin can realize multiple assignees on issues for review tasks by multiple people use case and so on.
  * send email notifications to users specified in the **Custom field** of the **User** format **when they are added or removed.** on issues.
  * send reminder to users specified in the **Custom field** of the **User** format
  * issues that users specified in the **Custom field** of the **User** format are queried as assignees such as **"My page" > "Issues assigned to me"**  
    *) Use "just Assignee" field instead to proceed query by the original scope of "assignee".

## Installation

1. To install the plugin

    `git clone` or copy an unarchived plugin(archived file is [here](https://github.com/hidakatsuya/redmine_default_custom_query/releases)) to `plugins/custom_users_as_assignees` on your Redmine path.

        cd {RAILS_ROOT}/plugins
        $ git clone https://github.com/preciousplum/custom_users_as_assignees 

2. Restart Redmine.

    Now you should be able to see the plugin in **Administration > Plugins**.  
    *) Migration is **not** required. 

## Compatibility
This plugin version is compatible with Redmine 3.3.0 and later in principle.
However, this plugin has been tested on Redmine 3.4.5 only currently.

## Special Thanks
This plugin was developed based on  notify_custom_users plugin.
https://github.com/Restream/notify_custom_users

