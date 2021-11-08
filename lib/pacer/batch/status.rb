# frozen_string_literal: true

module Pacer
  module Batch
    module Status
      COMPLETED = "COMPLETED"
      RUNNING   = "RUNNING"
      WAITING   = "WAITING"
      FAILED    = "FAILED"

      def completed?
        status == COMPLETED
      end

      def running?
        status == RUNNING
      end

      def waiting?
        status == WAITING
      end

      def failed?
        status == FAILED
      end
    end
  end
end
