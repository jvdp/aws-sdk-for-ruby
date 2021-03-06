# Copyright 2011 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

require 'aws/common'
require 'aws/inflection'
require 'aws/service_interface'
require 'aws/iam/client'
require 'aws/iam/user_collection'
require 'aws/iam/group_collection'
require 'aws/iam/signing_certificate_collection'
require 'aws/iam/server_certificate_collection'
require 'aws/iam/account_alias_collection'
require 'aws/iam/access_key_collection'

module AWS

  # This class is the starting point for working with 
  # AWS Identity and Access Management (IAM).
  #
  # For more information about IAM:
  #
  # * {AWS Identity and Access Management}[http://aws.amazon.com/iam/]
  # * {AWS Identity and Access Management Documentation}[http://aws.amazon.com/documentation/iam/]
  #
  # = Credentials
  #
  # You can setup default credentials for all AWS services via 
  # AWS.config:
  #
  #   AWS.config(
  #     :access_key_id => 'YOUR_ACCESS_KEY_ID',
  #     :secret_access_key => 'YOUR_SECRET_ACCESS_KEY')
  # 
  # Or you can set them directly on the IAM interface:
  #
  #   iam = AWS::IAM.new(
  #     :access_key_id => 'YOUR_ACCESS_KEY_ID',
  #     :secret_access_key => 'YOUR_SECRET_ACCESS_KEY')
  #
  # = Account Summary
  #
  # You can get account level information about entity usage and IAM quotas
  # directly from an IAM interface object.
  #
  #   summary = iam.account_summary
  #
  #   puts "Num users: #{summary[:users]}"
  #   puts "Num user quota: #{summary[:users_quota]}"
  #
  # For a complete list of summary attributes see the {#account_summary} method.
  #
  # = Account Aliases
  #
  # Currently IAM only supports a single account alias for each AWS account.
  # You can set the account alias on the IAM interface.
  #
  #   iam.account_alias = 'myaccountalias'
  #   iam.account_alias
  #   #=> 'myaccountalias'
  #
  # You can also remove your account alias:
  #
  #   iam.remove_account_alias
  #   iam.account_alias
  #   #=> nil
  #
  # = Access Keys
  #
  # You can create up to 2 access for your account and 2 for each user.
  # This makes it easy to rotate keys if you need to.  You can also
  # deactivate/activate access keys.
  #
  #   # get your current access key
  #   old_access_key = iam.access_keys.first
  #
  #   # create a new access key
  #   new_access_key = iam.access_keys.create
  #   new_access_key.credentials
  #   #=> { :access_key_id => 'ID', :secret_access_key => 'SECRET' }
  #
  #   # go rotate your keys/credentials ...
  #
  #   # now disable the old access key
  #   old_access_key.deactivate!
  #
  #   # go make sure everything still works ...
  #
  #   # all done, lets clean up
  #   old_access_key.delete
  #
  # Users can also have access keys:
  #
  #   u = iam.users['someuser']
  #   access_key = u.access_keys.create
  #   access_key.credentials
  #   #=> { :access_key_id => 'ID', :secret_access_key => 'SECRET' }
  #
  # See {AccessKeyCollection} and {AccessKey} for more information about
  # working with access keys.
  #
  # = Users & Groups
  #
  # Each AWS account can have multiple users.  Users can be used to easily
  # manage permissions.  Users can also be organized into groups.  
  #
  #   user = iam.users.create('JohnDoe')
  #   group = iam.groups.create('Developers')
  #
  #   # add a user to a group
  #   user.groups.add(group)
  #
  #   # remove a user from a group
  #   user.groups.remove(group)
  #
  #   # add a user to a group
  #   group.users.add(user)
  #
  #   # remove a user from a group
  #   group.users.remove(user)
  #
  # See {User}, {UserCollection}, {Group} and {GroupCollection} for more
  # information on how to work with users and groups.
  #
  # = Other Interfaces
  #
  # Other useful IAM interfaces:
  # * User Login Profiles ({LoginProfile})
  # * Policies ({Policy})
  # * Server Certificates ({ServerCertificateCollection}, {ServerCertificate})
  # * Signing Certificates ({SigningCertificateCollection}, {SigningCertificate})
  # * Multifactor Authentication Devices ({MFADeviceCollection}, {MFADevice})
  #
  class IAM

    include ServiceInterface

    # Returns a collection that represents all AWS users for this account:
    #
    # @example Getting a user by name
    #
    #   user = iam.users['username']
    #
    # @example Enumerating users
    #
    #   iam.users.each do |user|
    #     puts user.name
    #   end
    # 
    # @return [UserCollection] Returns a collection that represents all of
    #   the IAM users for this AWS account.
    def users
      UserCollection.new(:config => config)
    end

    # Returns a collection that represents all AWS groups for this account:
    #
    # @example Getting a group by name
    #
    #   group = iam.groups['groupname']
    #
    # @example Enumerating groups
    #
    #   iam.groups.each do |group|
    #     puts group.name
    #   end
    #
    # @return [GroupCollection] Returns a collection that represents all of
    #   the IAM groups for this AWS account.
    def groups
      GroupCollection.new(:config => config)
    end

    # Returns a collection that represents the access keys for this 
    # AWS account.
    #
    #   iam = AWS::IAM.new
    #   iam.access_keys.each do |access_key|
    #     puts access_key.id
    #   end
    #
    # @return [AccessKeyCollection] Returns a collection that represents all
    #   access keys for this AWS account.
    def access_keys
      AccessKeyCollection.new(:config => config)
    end

    # Returns a collection that represents the signing certificates
    # for this AWS account.  
    #
    #   iam = AWS::IAM.new
    #   iam.signing_certificates.each do |cert|
    #     # ...
    #   end
    #
    # If you need to access the signing certificates of a specific user,
    # see {User#signing_certificates}.
    # 
    # @return [SigningCertificateCollection] Returns a collection that
    #   represents signing certificates for this AWS account.
    def signing_certificates
      SigningCertificateCollection.new(:config => config)
    end

    # @note Currently, Amazon Elastic Load Balancing is the only
    #   service to support the use of server certificates with
    #   IAM. Using server certificates with Amazon Elastic Load
    #   Balancing is described in the
    #   {http://docs.amazonwebservices.com/ElasticLoadBalancing/latest/DeveloperGuide/US_SettingUpLoadBalancerHTTPSIntegrated.html
    #   Amazon Elastic Load Balancing} Developer Guide.
    #
    # Returns a collection that represents the server certificates
    # for this AWS account.
    #
    #   iam = AWS::IAM.new
    #   iam.server_certificates.each do |cert|
    #     # ...
    #   end
    #
    # @return [ServerCertificateCollection] Returns a collection that
    #   represents server certificates for this AWS account.
    def server_certificates
      ServerCertificateCollection.new(:config => config)
    end

    # Sets the account alias for this AWS account.
    # @param [String] account_alias
    # @return [String] Returns the account alias passed.
    def account_alias= account_alias
      account_alias.nil? ?
        remove_account_alias :
        account_aliases.create(account_alias)
    end

    # @return [String,nil] Returns the account alias.  If this account has
    #   no alias, then +nil+ is returned.
    def account_alias
      account_aliases.first
    end

    # Deletes the account alias (if one exists).
    # @return [nil] 
    def remove_account_alias
      account_aliases.each do |account_alias|
        account_aliases.delete(account_alias)
      end
      nil
    end

    # @private
    def account_aliases
      AccountAliasCollection.new(:config => config)
    end

    # Retrieves account level information about account entity usage
    # and IAM quotas.  The returned hash contains the following keys:
    #
    # [+:users+] Number of users for the AWS account
    #
    # [+:users_quota+] Maximum users allowed for the AWS account
    #
    # [+:groups+] Number of Groups for the AWS account
    #
    # [+:groups_quota+] Maximum Groups allowed for the AWS account
    #
    # [+:server_certificates+] Number of Server Certificates for the
    #                          AWS account
    #
    # [+:server_certificates_quota+] Maximum Server Certificates
    #                                allowed for the AWS account
    #
    # [+:user_policy_size_quota+] Maximum allowed size for user policy
    #                             documents (in kilobytes)
    #
    # [+:group_policy_size_quota+] Maximum allowed size for Group
    #                              policy documents (in kilobyes)
    #
    # [+:groups_per_user_quota+] Maximum number of groups a user can
    #                            belong to
    #
    # [+:signing_certificates_per_user_quota+] Maximum number of X509
    #                                          certificates allowed
    #                                          for a user
    #
    # [+:access_keys_per_user_quota+] Maximum number of access keys
    #                                 that can be created per user
    #
    # @return [Hash]
    def account_summary
      client.get_account_summary.summary_map.inject({}) do |h, (k,v)|
        h[Inflection.ruby_name(k).to_sym] = v
        h
      end
    end

  end
end
