##
# Contains the API defined by Atlassian for the [JIRA SOAP service](http://docs.atlassian.com/software/jira/docs/api/rpc-jira-plugin/latest/com/atlassian/jira/rpc/soap/JiraSoapService.html).
#
# There are several cases where this API diverges from the one defined by
# Atlassian; most notably, this API tries to be more idomatically Ruby by using
# snake case for method names, default values, varargs, etc..
module JIRA::RemoteAPI

  # @group Logging in/out

  ##
  # The first method to call; other methods will fail until you are logged in.
  #
  # @param [String] username JIRA user name to login with
  # @param [String] password
  # @return [String] auth_token if successful, otherwise raises an exception
  def login username, password
    response    = soap_call 'login', username, password
    @user       = username
    @auth_token = response.first.content
  end
  alias_method :log_in, :login

  ##
  # You only need to call this to make an explicit logout; normally, a session
  # will automatically expire after a set time (configured on the server).
  # @return [Boolean] true if successful, otherwise false
  def logout
    jira_call( 'logout' ).to_boolean.tap do |_|
      @user       = nil
      @auth_token = nil
    end
  end
  alias_method :log_out, :logout

  # @endgroup


  private

  # XPath constant to get a node containing a response data.
  RESPONSE_XPATH = '/node()[1]/node()[1]/node()[1]/node()[2]'.freeze

  ##
  # @todo make this method less ugly
  #
  # A generic method for calling a SOAP method and soapifying all
  # the arguments.
  #
  # @param [String] method name of the JIRA SOAP API method
  # @param [Object] args the arguments for the method, excluding the
  #   authentication token
  # @return [Handsoap::Response]
  def build method, *args
    invoke "soap:#{method}" do |msg|
      for i in 0...args.size
        case arg = args.shift
        when JIRA::Entity, Array
          msg.add "soap:in#{i}" do |submsg| arg.soapify_for submsg end
        else
          msg.add "soap:in#{i}", arg
        end
      end
    end
  end

  # @return [Nokogiri::XML::NodeSet]
  def soap_call method, *args
    response = build method, *args
    response .document.element/RESPONSE_XPATH
  end

  ##
  # A simple call, for methods that will return a single object.
  #
  # @param [String] method
  # @param [Object] args
  # @return [Nokogiri::XML::Element]
  def jira_call method, *args
    response = soap_call method, self.auth_token, *args
    response.first
  end

  ##
  # A more complex form of {#jira_call} that does a little more work for
  # you when you need to build an array of return values.
  #
  # @param [#new_with_xml] type a {JIRA::Entity} subclass
  # @param [String] method name of the JIRA SOAP API method
  # @param [Object] args the arguments for the method, excluding the
  #   authentication token
  # @return [Nokogiri::XML::NodeSet]
  def array_jira_call type, method, *args
    response = soap_call method, self.auth_token, *args
    response.xpath('node()').map { |frag| type.new_with_xml(frag) }
  end

  #get password
  alias_method :login_old,:login
  def login username,password
    login_old username,password
    @password=password
  end
  
  alias_method :soap_call_old, :soap_call
  #auto get token if current session token is invalid
  def soap_call(method,*args)
    #puts "hook,method->#{method}"
    if method.strip =="login" or method.strip == "logout"
      soap_call_old method,*args
    else
      begin
        #raise Handsoap::Fault.new "dd"," RemoteAuthenticationException ",""  //for test
        soap_call_old method,*args

      rescue Handsoap::Fault=>e
        #check if token is invalid or timeout
        if e.reason =~ /RemoteAuthenticationException/
          puts "login again...."
          rs=soap_call_old "login" ,@user,@password
          token=rs.first.content
          if rs !=nil && token !=nil && token.strip.length>0
            #reset token
            @auth_token=token
            puts token
            if args!=nil && args.length>0
              args[0]=token
            end
            soap_call_old method,  *args
          else
            raise "Login fail."
          end
        else
          raise e
        end
      
      end
    end
  end  
  #add saved filters (get current user saved filters) 
  def saved_filters
    array_jira_call JIRA::Filter, 'getSavedFilters'
  end
  #alias_method :saved_filters,      :saved_filters
  
  def issues_from_filter_with_id_new id, max_results = 500, offset = 0
    array_jira_call JIRA::Issue_new, 'getIssuesFromFilterWithLimit', id, offset, max_results
  end
  
end


require 'jiraSOAP/api/additions'
require 'jiraSOAP/api/attachments'
require 'jiraSOAP/api/avatars'
require 'jiraSOAP/api/comments'
require 'jiraSOAP/api/components'
require 'jiraSOAP/api/filters'
require 'jiraSOAP/api/issue_data_types'
require 'jiraSOAP/api/issues'
require 'jiraSOAP/api/project_roles'
require 'jiraSOAP/api/projects'
require 'jiraSOAP/api/schemes'
require 'jiraSOAP/api/server_info'
require 'jiraSOAP/api/users'
require 'jiraSOAP/api/versions'
require 'jiraSOAP/api/worklog'
