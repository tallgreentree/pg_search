require "active_support/concern"
require "active_support/core_ext/class/attribute"

module PgSearch
  module Multisearchable
    extend ActiveSupport::Concern

    included do
      has_one :pg_search_document,
        :as => :searchable,
        :class_name => "PgSearch::Document",
        :dependent => :delete

      after_create :create_pg_search_document,
        :if => lambda { PgSearch.multisearch_enabled? and self.approval_status == 'approved' and self.include_in_search }

      after_update :update_pg_search_document,
        :if => lambda { PgSearch.multisearch_enabled? }
    end

    def update_pg_search_document
      create_pg_search_document unless self.pg_search_document
      unless self.approval_status == 'approved' and self.include_in_search
        self.pg_search_document.content = ''
      end
      self.pg_search_document.save
    end
  end
end
