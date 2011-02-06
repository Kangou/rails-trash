module Trash

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    ##
    #   class Entry < ActiveRecord::Base
    #     has_trash
    #   end
    #
    def has_trash
      extend ClassMethodsMixin
      include InstanceMethods
      alias_method_chain :destroy, :trash
    end

    module ClassMethodsMixin

      def deleted
        unscoped.where("#{self.table_name}.deleted_at IS NOT NULL")
      end

    end

    module InstanceMethods

      def destroy_with_trash
        return destroy_without_trash if @trash_is_disabled
        self.update_attribute(:deleted_at, Time.now.utc)
      end

      def restore
        self.update_attribute(:deleted_at, nil)
      end

      def disable_trash
        save_val = @trash_is_disabled
        begin
          @trash_is_disabled = true
          yield if block_given?
        ensure
          @trash_is_disabled = save_val
        end
      end

    end

  end
end

ActiveRecord::Base.send :include, Trash
