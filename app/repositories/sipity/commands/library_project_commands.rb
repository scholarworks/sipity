require 'jira'
module Sipity
  # :nodoc:
  module Commands
    # Commands
    module LibraryProjectCommands
      def create_jira_issue_for(entity:, status:, repository: self)
        work = Conversions::ConvertToWork.call(entity)
        project_issue_type = repository.work_attribute_values_for(work: work, key: 'project_issue_type', cardinality: 1)

        options = {
          username: Figaro.env.jira_username!, password: Figaro.env.jira_password!, site: Figaro.env.jira_site_url!,
          context_path: '', auth_type: :basic, use_ssl: true
        }
        client = JIRA::Client.new(options)
        darit_project = client.Project.find('DARIT')
        json = {
          "project" => { "id" => darit_project.id }, "summary" => "TEST - #{work.title}", "issuetype" => { "name" => project_issue_type }
        }
        issue = client.Issue.build
        issue.save!("fields" => json)
        json
      end
    end
  end
end
