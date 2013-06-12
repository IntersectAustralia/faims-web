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

							params.push(Param.new(param['type'], param['value']))
						
						end

						if validator['type'] == 'evaluator'
							validators.push(EvalValidator.new(params, validator['cmd']))
						elsif validator['type'] == 'blankchecker'
							validators.push(BlankValidator.new(params))
						elsif validator['type'] == 'typechecker'
							validators.push(TypeValidator.new(params, validator['datatype']))
						elsif validator['type'] == 'querychecker'
							validators.push(QueryValidator.new(params, validator['query']))
						else
							raise 'Invalid validator type ' + validator['type']
						end

					end

					properties[property['name]']] = validators
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

							params.push(Param.new(param['type'], param['value']))
						
						end

						if validator['type'] == 'evaluator'
							validators.push(EvalValidator.new(params, validator['cmd']))
						elsif validator['type'] == 'blankchecker'
							validators.push(BlankValidator.new(params))
						elsif validator['type'] == 'typechecker'
							validators.push(TypeValidator.new(params, validator['datatype']))
						elsif validator['type'] == 'querychecker'
							validators.push(QueryValidator.new(params, validator['query']))
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

			validators.each do |validator|
				result = validator.validate(uuid, aentvaluetimestamp, fields)
				return result if result
			end

			nil
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

			validators.each do |validator|
				result = validator.validate(relationshipid, relnvaluetimestamp, fields)
				return result if result
			end

			nil
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
			return db.execute(@value, id, timestamp) if @type == 'query'
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

	def validate
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
			temp_file = Tempfile.new('tmp')
			temp_cmd = @cmd
			@params.each do |p|
				temp_cmd = temp_cmd.sub("?", p.get_value(db, id, timestamp, fields))
			end
			result = system "#{temp_cmd} 1>>#{temp_file.path} 2>>#{temp_file.path}"
			return nil if result
			error = temp_file.read
			return error
		rescue Exception => e
			return e.to_s
		ensure
			temp_file.unlink if temp_file
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
				return "Value is Blank" if p.get_value(db, id, timestamp, fields).blank?
			end
			return nil
		rescue Exception => e
			return e.to_s
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
				return "Value not an integer" if @datatype == 'integer' and !integer(value)
				return "Value not a float" if @datatype == 'float' and !float(value)
				return "Value not a string" if value.blank?
			end
			return nil
		rescue Exception => e
			return e.to_s
		end	
	end

	def integer?(value)
		begin
			Integer(value)
			return true
		rescue Exception => e
			return false
		end
	end

	def float?(value)
		begin
			Float(value)
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
			params.each do |p|
				values.push(p.get_value(db, id, timestamp, fields))
			end
			result = db.execute(db, *values)
			return nil if result and result[0]
			return result[1]
		rescue Exception => e
			return e.to_s
		end	
	end
end