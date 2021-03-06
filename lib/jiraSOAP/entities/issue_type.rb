##
# Contains all the metadata for an issue type.
class JIRA::IssueType < JIRA::IssueProperty

  add_attribute :name,'name',:content
  
  ##
  # True if the issue type is also a subtask
  #
  # @return [Boolean]
  add_attribute :subtask, 'subTask', :to_boolean
  alias_method :sub_task, :subtask
  alias_method :sub_task=, :subtask=
  alias_method :sub_task?, :subtask

end
