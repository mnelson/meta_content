module MetaContent
  class Query
    
    def initialize(record)
      @record = record
    end

    def select_all
      sql = "SELECT #{qtn}.lookup, #{qtn}.value FROM #{qtn} WHERE #{qtn}.object_id = #{pk}"
      results = {}
      execute(sql).each do |row|
        results[row[0]] = row[1]
      end
      results
    end

    def update_all(changes)
      sql = "INSERT INTO #{qtn}(object_id,lookup,value) VALUES "
      sql << changes.map do |k,v|
        "(#{pk},'#{k}','#{v}')"
      end.join(',')
      sql << " ON DUPLICATE KEY UPDATE value = VALUES(value)"
      execute(sql)
    end

    def delete_all(keys)
      key_clause = keys.map{|k| "'#{k}'" }.join(',')
      sql = "DELETE FROM #{qtn} WHERE #{qtn}.object_id = #{pk} AND #{qtn}.lookup IN (#{key_clause})"
      execute(sql)
    end

    protected

    def qtn
      "`#{klass.table_name}_meta`"
    end

    def pk
      @record.id
    end

    def klass
      @record.class
    end

    def execute(sql)
      klass.connection.execute(sql)
    end

  end
end