class DatabaseValidator

	def initialize(db, filename)
		@db = db
		@relationship_validators = {}
		@entity_validators = {}
		File.open(filename) do |f|
			doc = Nokogiri::XML(f)
			doc.xpath("//RelationshipElement").each do |relationship|
				properties = {}

				relationship.xpath("./property").each do |property|
					validators = []

					property.xpath("./validator").each do |validator|
						params = []

						validator.xpath("./param").each do |param|

							raise "Invalid param type " + param['type'] unless param['type'] == 'field' or param['type'] == 'query'

              value = param.xpath("./value").first
              value ||= param['value']
							if param['type'] == 'field'
								raise "Invalid value type " + value unless value == 'freetext' or
                    value == 'vocab' or
                    value == 'certainty'
							end

							params.push(Param.new(param['type'], value))
						
						end

						if validator['type'] == 'evaluator'
              cmd = validator.xpath("./cmd").first

							validators.push(EvalValidator.new(params, cmd ? cmd.text : validator['cmd']))
						elsif validator['type'] == 'blankchecker'
							validators.push(BlankValidator.new(params))
						elsif validator['type'] == 'typechecker'
							validators.push(TypeValidator.new(params, validator['datatype']))
            elsif validator['type'] == 'querychecker'
              query = validator.xpath("./query").first

							validators.push(QueryValidator.new(params, query ? query.text : validator['query']))
						else
							raise 'Invalid validator type ' + validator['type']
						end

					end

					properties[property['name']] = validators
				end

				@relationship_validators[relationship['name']] = properties
			end

			doc.xpath("//ArchaeologicalElement").each do |entity| 
				properties = {}

				entity.xpath("./property").each do |property|
					validators = []

					property.xpath("./validator").each do |validator|
						params = []

						validator.xpath("./param").each do |param|

							raise "Invalid param type " + param['type'] unless param['type'] == 'field' or param['type'] == 'query'

              value = param.xpath("./value").first
              value ||= param['value']
              if param['type'] == 'field'
                raise "Invalid value type " + value unless value == 'freetext' or
                    value == 'vocab' or
                    value == 'certainty' or
                    value == 'measure'
              end

							params.push(Param.new(param['type'], param['value']))
						
						end

						if validator['type'] == 'evaluator'
              cmd = validator.xpath("./cmd").first

              validators.push(EvalValidator.new(params, cmd ? cmd.text : validator['cmd']))
						elsif validator['type'] == 'blankchecker'
							validators.push(BlankValidator.new(params))
						elsif validator['type'] == 'typechecker'
							validators.push(TypeValidator.new(params, validator['datatype']))
						elsif validator['type'] == 'querychecker'
              query = validator.xpath("./query").first

              validators.push(QueryValidator.new(params, query ? query.text : validator['query']))
						else
							raise 'Invalid validator type ' + validator['type']
						end

					end

					properties[property['name']] = validators
				end

				@entity_validators[entity['type']] = properties
      end

		end

	end

	def validate_aent_value(uuid, aentvaluetimestamp, attributename, fields)
		begin
			type = @db.get_arch_entity_type(uuid)

			properties = @entity_validators[type]

			return nil unless properties

			validators = properties[attributename]

			return nil unless validators

			#p validators
			#p 'Attribute: ' + attributename if attributename
			#p 'Fields: ' + fields.to_s if fields

			result = ''
			validators.each do |validator|
				r = validator.validate(@db.spatialite_db, uuid, aentvaluetimestamp, fields)
				if r
					if result
						result = result + ';' + r.to_s if r
					else
						result = r.to_s
					end
				end
			end

			return nil if result.blank?
			return result
		rescue Exception => e
			raise e
		end
	end

	def validate_reln_value(relationshipid, relnvaluetimestamp, attributename, fields)
		begin
			type = @db.get_relationship_type(relationshipid)

			properties = @relationship_validators[type]

			return nil unless properties

			validators = properties[attributename]
			
			return nil unless validators

			#p validators
			#p 'Attribute: ' + attributename if attributename
			#p 'Fields: ' + fields.to_s if fields

			result = nil
			validators.each do |validator|
				r = validator.validate(@db.spatialite_db, relationshipid, relnvaluetimestamp, fields)
				if r
					if result
						result = result + ';' + r.to_s if r
					else
						result = r.to_s
					end
				end
			end

			return nil if result.blank?
			return result
		rescue Exception => e
			raise e
		end
	end

end

class Param

	def initialize(type, value)
		@type = type
		@value = value
	end

	def type
		@type
	end

	def value
		@value
	end

	def get_value(db, id, timestamp, fields)
		begin
			return db.execute(@value, id, timestamp).first.first if @type == 'query'
			return fields[value]
		rescue Exception => e
			raise e
		end
	end

end

class AttributeValidator

	def initialize(params)
		@params = params
	end

	def validate(db, id, timestamp, fields)
		raise 'Not Implemented'
	end

end

class EvalValidator < AttributeValidator

	def initialize(params, cmd)
		super(params)
		@cmd = cmd
	end

	def validate(db, id, timestamp, fields)
		begin
			temp_cmd = @cmd
			@params.each do |p|
        v = p.get_value(db, id, timestamp, fields)
        v ||= ''
				temp_cmd = temp_cmd.sub('?', v.to_s)
			end
			result = system temp_cmd
			return nil if result
			f = IO.popen temp_cmd
			return f.readlines.join
    rescue Exception => e
      puts e.to_s
      puts e.backtrace
			return 'Error in evaluator'
		end	
	end

end

class BlankValidator < AttributeValidator
	def initialize(params)
		super(params)
	end

	def validate(db, id, timestamp, fields)
		begin
			@params.each do |p|
				return "Field value is blank" if p.get_value(db, id, timestamp, fields).blank?
			end
			return nil
		rescue Exception => e
      puts e.to_s
      puts e.backtrace
      return 'Error in blank checker'
		end	
	end
end

class TypeValidator < AttributeValidator
	def initialize(params, datatype)
		super(params)
		@datatype = datatype
	end

	def validate(db, id, timestamp, fields)
		begin
			@params.each do |p|
				value = p.get_value(db, id, timestamp, fields)
				return "Field value not an integer" if @datatype == 'integer' and !integer?(value)
				return "Field value not a real" if @datatype == 'real' and !float?(value)
				return "Field value not text" if value.blank?
			end
			return nil
		rescue Exception => e
      puts e.to_s
      puts e.backtrace
      return 'Error in type checker'
		end	
	end

	def integer?(value)
		begin
			Integer(value.to_s)
			return true
		rescue Exception => e
			return false
		end
	end

	def float?(value)
		begin
			Float(value.to_s)
			return true
		rescue Exception => e
			return false
		end
	end
end

class QueryValidator < AttributeValidator
	def initialize(params, query)
		super(params)
		@query = query
	end

	def validate(db, id, timestamp, fields)
		begin
			values = []
			@params.each do |p|
				values.push(p.get_value(db, id, timestamp, fields))
      end
			result = db.execute(@query, *values)
			return nil if result[0][0] == 1
			return result[0][1]
		rescue Exception => e
      puts e.to_s
      puts e.backtrace
      return 'Error in query checker'
		end	
	end
end