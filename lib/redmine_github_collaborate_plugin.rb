require 'uri'
require 'net/http'
require 'json'

module RedmineGithubCollaboratePlugin
  module GithubURLs
    def on_issue_url(userId,repoId,issueId)
      url_str = "https://api.github.com/repos/#{userId}/#{repoId}/issues/#{issueId}"

      Rails.cache.clear
      response = Rails.cache.fetch(url_str, expires_in: 1.days) do
        Net::HTTP.get_response(URI(url_str))
      end
      
      if response.is_a?(Net::HTTPSuccess)
        issue = JSON.parse(response.body)

        is_open = issue["state"] == "open"
        image_file = is_open ? "issue-opened.svg" : "issue-closed.svg"
        image_url = "#{::Redmine::Utils.relative_url_root}/plugin_assets/redmine_github_collaborate/images/#{image_file}"
        image_tag = "<img src='#{image_url}' alt='#{is_open ? "opened" : "closed"}' style='width: 16px;' />"

        return %(<a href="#{issue["html_url"]}">#{image_tag}#{issue["title"]} ##{issue["number"]}</a>)
      elsif response.is_a?(Net::HTTPNotFound)
        return %(<div style="color: red;">Not found #{uri} you probably don't have permission.</div>)
      else
        raise
      end
    end

    def on_github_url(url)
      parts = url.split("/")
      begin
        if parts.length > 6 then
          case parts[5]
          when "issues"
            return on_issue_url(parts[3],parts[4],parts[6])
          end
        end
      rescue => e
      end
      return url
    end

    def to_html(*args)
      @text = @text.gsub(/https\:\/\/github\.com\/[^\s\n]*/){ |match| on_github_url(match) }
      super(*args)
    end
  end
end
