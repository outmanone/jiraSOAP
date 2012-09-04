##
# Contains all the metadata for a resolution.
class JIRA::Resolution < JIRA::IssueProperty
    add_attribute :name,'name',:content
end
