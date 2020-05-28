### Copyright 2019 Rixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

module JSS

    # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A Dock Item in the JSS.
  # These are rather simple. They have an ID, name, path, type, and contents which is read-only
  #
  # @see JSS::APIObject
  #
  class DirectoryBinding < JSS::APIObject

    # JSS > directorybinding.rb
    # folder directory binding type
    ## Includes type
    ##! Requires in right way
    #class DirectoryBindingType
    #    def test1
    #        puts "Test1"
    #    end

        #? Look at scope obj (policy rest_xml)
        #def rest_xml

        #end
    #end

    #class ActiveDirectory < DirectoryBindingType
    #    RSRC_OBJECT_KEY = :active_directory
    #    # Settings for this obj
    #    def test2
    #        puts "Test2"
    #    end

    #end

        # Mix-Ins
        #####################################
        include JSS::Creatable
        include JSS::Updatable
        include JSS::DirectoryBindingType

        # Class Methods
        #####################################

        # Class Constants
        #####################################

        #! You CAN update this
        DIRECTORY_BINDING_TYPE = {
            open_directory: "Open Directory",
            active_directory: "Active Directory",
            powerbroker_identity_services: "PowerBroker Identity Services",
            admitmac: "ADmitMac",
            centrify: "Centrify"
        }.freeze

        DIRECTORY_BINDING_TYPE_CLASSES = {
            "Open Directory" => JSS::DirectoryBindingType::OpenDirectory,
            "Active Directory" => JSS::DirectoryBindingType::ActiveDirectory,
            "PowerBroker Identify Services" => JSS::DirectoryBindingType::PowerBroker,
            "ADmitMac" => JSS::DirectoryBindingType::ADmitMac,
            "Centrify" => JSS::DirectoryBindingType::Centrify
        }

        DIRECTORY_NETWORK_PROTOCOL = {
            smb: "SMB",
            afp: "AFP"
        }.freeze

        # The base for REST resources of this class
        RSRC_BASE = 'directorybindings'.freeze

        # the hash key used for the JSON list output of all objects in the JSS
        RSRC_LIST_KEY = :directory_bindings

        # The hash key used for the JSON object output.
        # It's also used in various error messages
        RSRC_OBJECT_KEY = :directory_binding

        # the object type for this object in
        # the object history table.
        # See {APIObject#add_object_history_entry}
        #OBJECT_HISTORY_OBJECT_TYPE = 41

        # Attributes
        #####################################
        attr_reader :id
        attr_reader :name
        attr_reader :priority
        attr_reader :domain
        attr_reader :username
        attr_reader :password_sha256
        attr_reader :computer_ou
        attr_reader :type
        attr_reader :type_settings

        # Constructor
        # @see JSS::APIObject.initialize
        #####################################
        def initialize(args = {})
            super args

            @priority = @init_data[:priority]
            @domain = @init_data[:domain]
            @username = @init_data[:username]
            @password_sha256 = @init_data[:password_sha256]
            @computer_ou = @init_data[:computer_ou]
            @type = @init_data[:type]

            # The different type of directory binding settings:
            #? One attribute "type-settings" instance of directory binding type DirectoryBindingType

            class_key = DIRECTORY_BINDING_TYPE.select { |k,v| v == @type }.map { |k,v| k }.first

            #@type_settings = DIRECTORY_BINDING_TYPE_CLASSES[@type.to_s].new @init_data[class_key]
            self.set_type_settings (DIRECTORY_BINDING_TYPE_CLASSES[@type.to_s].new @init_data[class_key])
        end

        # Public Instance Methods
        #####################################

        # The domain the device will be bound to.
        #
        # @author Tyler Morgan
        #
        # @param newvalue [String]
        #
        # @raise [JSS::InvalidDataError] If newvalue is not a String
        #
        # @return [void]
        def domain=(newvalue)
            raise JSS::InvalidDataError, "Domain must be a String" unless newvalue.is_a? String

            @domain = newvalue.to_s
            @need_to_update = true
        end


        # The username used to attempt to bind the device to the domain.
        #
        # @author Tyler Morgan
        #
        # @param newvalue [String]
        #
        # @raise [JSS::InvalidDataError] If newvalue is not a String
        #
        # @return [void]
        def username=(newvalue)
            raise JSS::InvalidDataError, "Username must be a String" unless newvalue.is_a? String

            @username = newvalue
            @need_to_update = true
        end


        # The priority the domain has over another one.
        #
        # @author Tyler Morgan
        #
        # @param newvalue [Integer]
        #
        # @raise [JSS::InvalidDataError] If newvalue is not an Integer
        # @raise [JSS::InvalidDataError] If newvalue is not between 1 and 10
        #
        # @return [void]
        def priority=(newvalue)
            raise JSS::InvalidDataError, "Priority must be a Integer" unless newvalue.is_a? Integer
            raise JSS::InvalidDataError, "Priority cannot exceed 10" unless newvalue <= 10
            raise JSS::InvalidDataError, "Priority must be greater than 0" unless newvalue > 0

            @priority = newvalue
            @need_to_update = true
        end

        
        # The OU path the computer object is to be placed
        #
        # @author Tyler Morgan
        #
        # @param newvalue [String]
        #
        # @raise [JSS::InvalidDataError] If newvalue is not a String
        #
        # @return [void]
        def computer_ou=(newvalue)
            raise JSS::InvalidDataError, "Computer OU must be a String" unless newvalue.is_a? String

            @computer_ou = newvalue
            @need_to_update = true
        end

        # private instance methods
        ######################
        private

        # the xml formated data for adding or updating this in the JSS
        #
        # This method constructs a properly formatted XML document to be handled by the Jamf Pro API
        #
        # @author Tyler Morgan
        #
        # @return [String]
        def rest_xml
            doc = REXML::Document.new APIConnection::XML_HEADER
            ns = doc.add_element RSRC_OBJECT_KEY.to_s
            ns.add_element('id').text = @id.to_s
            ns.add_element('name').text = @name
            ns.add_element('priority').text = @priority.to_s
            ns.add_element('domain').text = @domain.to_s
            ns.add_element('username').text = @username.to_s
            ns.add_element('computer_ou').text = @computer_ou.to_s
            ns.add_element('type').text = @type.to_s

            ns << @type_settings.type_setting_xml

            return doc.to_s
        end # rest_xml
    end


end