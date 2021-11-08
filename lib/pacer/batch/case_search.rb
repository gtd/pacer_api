# frozen_string_literal: true

require "pacer/case_info"
require "pacer/batch/status"

module Pacer
  module Batch
    class CaseSearch
      include Batch::Status

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

      def initialize(session, report_info)
        @session = session
        @report_info = report_info
        @report_id = report_info.fetch(:report_id)
      end

      def download_fee
        @report_info.fetch(:download_fee, nil)
      end

      def record_count
        @report_info.fetch(:record_count, nil)
      end

      def poll!
        @report_info = @session.get(format(STATUS_PATH, @report_id))
      end

      def download
        Download.new(@session.get(format(DOWNLOAD_PATH, @report_id)))
      end

      def download_xml
        @session.request(:get, format(DOWNLOAD_PATH, @report_id)) { |req|
          req.headers["Accept"] = "application/xml"
        }.body
      end

      def delete
        @session.delete(format(DELETE_PATH, @report_id))
      end

      def status
        @report_info.fetch(:status)
      end

      Download = Struct.new(:payload) do
        def cases
          payload.fetch(:content).map { |h| CaseInfo.new(h) }
        end
      end
    end
  end
end
