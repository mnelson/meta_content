module MetaContent
  class Query
    
    def initialize(record)
      @record = record
    end

    def select_all
      sql = "SELECT #{qtn}.lookup, #{qtn}.value FROM #{qtn} WHERE #{qtn}.object_id = #{quote(pk)}"
      results = {}
      execute(sql).each do |row|
        results[row[0]] = row[1]
      end
      results
    end

    def update_all(changes)
      values = changes.map do |k,v|
        "(#{quote(pk)},#{quote(k)},#{quote(v)})"
      end
      return unless values.any?

      sql = "INSERT INTO #{qtn}(object_id,lookup,value) VALUES " 
      sql << values.join(',')
      sql << " ON DUPLICATE KEY UPDATE value = VALUES(value)"
      execute(sql)
    end

    def delete_all(deletes)
      return unless deletes.any?
      key_clause = deletes.map{|k| quote(k) }.join(',')
      sql = "DELETE FROM #{qtn} WHERE #{qtn}.object_id = #{quote(pk)} AND #{qtn}.lookup IN (#{key_clause})"
      execute(sql)
    end

    protected

    def qtn
      klass.connection.quote_table_name("#{klass.table_name}_meta")
    end

    def quote(value)
      klass.quote_value(value)
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