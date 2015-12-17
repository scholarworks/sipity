require 'spec_helper'
require 'sipity/commands/library_project_commands'

module Sipity
  module Commands
    RSpec.describe LibraryProjectCommands, type: :isolated_repository_module do
      subject { test_repository }
      it { should respond_to(:create_jira_issue_for) }
    end
  end
end
