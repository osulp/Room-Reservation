# Monkey patch in requiring nsec as the cache timestamp format.
module ActiveRecord
  class Base
    self.cache_timestamp_format = :nsec
  end
end
if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
  module ActiveRecord
    module ConnectionAdapters
      class Mysql2Adapter < AbstractMysqlAdapter
        def type_to_sql(type, limit=nil, precision=nil, scale=nil)
          case type.to_s
          when 'datetime'
            return super unless precision
            case precision
              when 0..6; "datetime(#{precision})"
              else raise(ActiveRecordError, "No timestamp type has precision of #{precision}. The allowed range of precision is from 0 to 6")
            end
          else
            super
          end
        end

        def quoted_date(value)
          if value.acts_like?(:time) && value.respond_to?(:usec)
            "#{super}.#{sprintf("%06d", value.usec)}"
          else
            super
          end
        end
        private

        def extract_limit(sql_type)
          case sql_type
          when /^timestamp/i; nil
          else super
          end
        end

        def extract_precision(sql_type)
          if sql_type =~ /timestamp/i
            $1.to_i if sql_type =~ /\((\d+)\)/
          else
            super
          end
        end
      end
    end
  end
end