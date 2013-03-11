module MetaContent
  class Query
    
    def initialize(record)
      @record = record
    end

    def select_all
      sql = "SELECT #{qtn}.scope, #{qtn}.lookup, #{qtn}.value FROM #{qtn} WHERE #{qtn}.object_id = #{pk}"
      results = {}
      execute(sql).each do |row|
        results[row[0]] ||= {}
        results[row[0]][row[1]] = row[2]
      end
      results
    end

    def update_all(changes)
      sql = "INSERT INTO #{qtn}(scope,object_id,lookup,value) VALUES "
      values = changes.map do |scope, scoped_changes|
        scoped_changes.map do |k,v|
          "('#{scope}',#{pk},'#{k}','#{v}')"
        end
      end.flatten
      sql << values.join(',')
      sql << " ON DUPLICATE KEY UPDATE value = VALUES(value)"
      execute(sql) if values.any?
    end

    def delete_all(deletes)
      deletes.each do |scope, keys|
        next unless keys.any?
        key_clause = keys.map{|k| "'#{k}'" }.join(',')
        sql = "DELETE FROM #{qtn} WHERE #{qtn}.object_id = #{pk} AND #{qtn}.scope = '#{scope}' AND #{qtn}.lookup IN (#{key_clause})"
        execute(sql)
      end
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