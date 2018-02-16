#
module JSS

  #
  module ManagementHistory

    # MobileDeviceApp - an app deployed to a MobileDevice
    #
    # This should only be instantiated by the ManagementHistory.app_history method
    # when mixed in to Mobile devices.
    #
    # That method will return an array of these objects.
    #
    # NOTE: some attributes will be nil for some statuses
    # (e.g. no size data if not installed)
    #
    class MobileDeviceApp < ImmutableStruct.new(

      :name,
      :version,
      :short_version,
      :management_status,
      :source,
      :bundle_size,
      :dynamic_size
    )

      include JSS::ManagementHistory::HashLike

      # @!attribute [r] name
      #   @return [String] the name of the app.

      # @!attribute [r] version
      #   @return [String] The version of the app

      # @!attribute [r] short_version
      #   @return [String] The short_version of the app

      # @!attribute [r] management_status
      #  @return [String] The raw status, used for #managed? and #status

      # @!attribute [r] source
      #   @return [Symbol] :in_house, :app_store, or :other

      # @!attribute [r] bundle_size
      #   @return [String] The size of the app bundle as text, e.g. '28 MB'

      # @!attribute [r] dynamic_size
      #   @return [String] The dynamic size of the app as text, e.g. '28 MB'

      # @return [Symbol] :installed, :pending, :failed, or :unknown
      #
      def status
        case @management_status
        when HIST_RAW_STATUS_INSTALLED then :installed
        when HIST_RAW_STATUS_MANAGED then :installed
        when HIST_RAW_STATUS_UNMANAGED then :installed
        when HIST_RAW_STATUS_PENDING then :pending
        when HIST_RAW_STATUS_FAILED then :failed
        else :unknown
        end
      end

      #  @return [Boolean] If :installed and :in_house, is it managed?
      #
      def managed?
        @management_status == HIST_RAW_STATUS_MANAGED
      end

      # @return [Integer] The size of the app bundle in kb, e.g. 29033
      #
      def bundle_size_kb
        size_to_kb @bundle_size if @bundle_size
      end

      # @return [Integer] The dynamic size of the app in kb, e.g. 29033
      #
      def dynamic_size_kb
        size_to_kb @dynamic_size if @dynamic_size
      end

      # @param [String] A raw size value from the API
      #
      # @return [Integer] the size as an integer of Kb
      #
      def size_to_kb(raw_size)
        val, unit = raw_size.split ' '
        val = val.to_i
        case unit.downcase
        when 'kb' then val
        when 'mb' then val * 1024
        when 'gb' then val * 1024 * 1024
        end # case unit
      end
      private :size_to_kb

    end # MobileDeviceApp

  end # module ManagementHistory

end # module JSS
