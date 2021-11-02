# frozen_string_literal: true

require "pacer/case_info"

module Pacer
  module Batch
    class CaseSearch
      SEARCH_PATH   = "cases/download"
      STATUS_PATH   = "cases/download/status/%d"
      DOWNLOAD_PATH = "cases/download/%d"
      DELETE_PATH   = "cases/reports/%d"
      LIST_PATH     = "cases/reports"

      def self.create(session, params)
        payload = session.post(SEARCH_PATH, params)
        new(session, payload)
      end

      def self.all(session)
        payload = session.get(LIST_PATH)
        payload.fetch(:content).map { |doc| new(session, doc) }
      end

      def initialize(session, status)
        @session = session
        @status = status
        @report_id = status.fetch(:report_id)
      end

      def completed?
        @status.fetch(:status, nil) == "COMPLETED"
      end

      def poll!
        @status = @session.get(format(STATUS_PATH, @report_id))
      end

      def download
        Download.new(@session.get(format(DOWNLOAD_PATH, @report_id)))
      end

      def delete
        @session.delete(format(DELETE_PATH, @report_id))
      end

      Download = Struct.new(:payload) do
        def cases
          payload.fetch(:content).map { |h| CaseInfo.new(h) }
        end
      end
    end
  end
end
