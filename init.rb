require File.dirname(__FILE__) + '/lib/redmine_github_collaborate_plugin'

Redmine::Plugin.register :redmine_github_collaborate do
  name 'Redmine Github Collaborate plugin'
  author 'shiron4710'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/shiron4710/redmine_github_collaborate'
  author_url 'https://github.com/shiron4710'
end


Rails.application.config.after_initialize do
  Redmine::WikiFormatting.format_names.each do |format_name|
    formatter = Redmine::WikiFormatting.formatter_for(format_name)
    if format_name == "common_mark" then
      formatter.prepend(RedmineGithubCollaboratePlugin::GithubURLs)
    end
  end
end
