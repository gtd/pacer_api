# frozen_string_literal: true

require "pacer/party_info"

module Pacer
  module Batch
    class PartySearch
      SEARCH_PATH   = "parties/download"
      STATUS_PATH   = "parties/download/status/%d"
      DOWNLOAD_PATH = "parties/download/%d"
      DELETE_PATH   = "parties/reports/%d"
      LIST_PATH     = "parties/reports"

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

      def download_fee
        @status.fetch(:download_fee, nil)
      end

      def record_count
        @status.fetch(:record_count, nil)
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
        def parties
          payload.fetch(:content).map { |h| PartyInfo.new(h) }
        end
      end
    end
  end
end
