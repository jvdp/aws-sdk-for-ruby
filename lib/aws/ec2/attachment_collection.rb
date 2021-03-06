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

require 'aws/model'
require 'aws/ec2/volume'
require 'aws/ec2/instance'
require 'aws/ec2/attachment'

module AWS
  class EC2

    # Represents the collection of attachments for an Amazon EBS
    # volume.
    #
    # @see Volume
    class AttachmentCollection

      include Model
      include Enumerable

      attr_reader :volume

      # @private
      def initialize volume, options = {}
        @volume = volume
        super
      end

      # @yield [attachment] Each attachment of the volume as an
      #   {Attachment} object.
      # @return [nil]
      def each &block
        volume.attachment_set.each do |item|

          instance = Instance.new(item.instance_id, :config => config)

          attachment = Attachment.new(self.volume, instance, item.device, 
            :config => config)

          yield(attachment)

        end
        nil
      end

    end

  end
end
