class DatabaseValidator

	def initialize(db, filename)
		@db = db
		@relationship_validators = {}
		@entity_validators = {}
		File.open(filename) do |f|
			doc = Nokogiri::XML(f)
			doc.xpath("//RelationshipElement").each |relationship| 
				properties = {}

				relationship.xpath("./property").each do |property|
					validators = []

					property.xpath("./validator").each do |validator|
						params = []

						validator.xpath("./param").each do |param|

							raise "Invalid param type " + param.type unless param.type == 'field' or param.type == 'query'

							params.push(Param.new(param.type, param.value))
						
						end

						if validator.type == 'evaluator'
							validators.push(EvalValidator.new(params))
						elsif validator.type == 'blankchecker'
							validators.push(BlankValidator.new(params))
						elsif validator.type == 'typechecker'
							validators.push(TypeValidator.new(params))
						elsif validator.type == 'querychecker'
							validators.push(QueryValidator.new(params))
						else
							raise 'Invalid validator type ' + validator.type
						end

					end

					properties[property.name] = validators
				end

				relationship_validators[relationship.name] = properties
			end

			doc.xpath("//ArchaeologicalElement").each |entity| 
				properties = {}

				entity.xpath("./property").each do |property|
					validators = []

					property.xpath("./validator").each do |validator|
						params = []

						validator.xpath("./param").each do |param|

							raise "Invalid param type " + param.type unless param.type == 'field' or param.type == 'query'

							params.push(Param.new(param.type, param.value))
						
						end

						if validator.type == 'evaluator'
							validators.push(EvalValidator.new(params))
						elsif validator.type == 'blankchecker'
							validators.push(BlankValidator.new(params))
						elsif validator.type == 'typechecker'
							validators.push(TypeValidator.new(params))
						elsif validator.type == 'querychecker'
							validators.push(QueryValidator.new(params))
						else
							raise 'Invalid validator type ' + validator.type
						end

					end

					properties[property.name] = validators
				end

				entity_validators[entity.type] = properties
			end
		end
	end

	def validate_arch_ent(uuid, timestamp)
		# 1. Get ArchEntity Type
		# 2. Find validators for type
		# 3. Run Validators against record
	end

	def validate_relationship(relationshipid, timestamp)

	end

end

class Param

	def initialize(type, value)
		@type = type
		@value = @value
	end

	def type
		@type
	end

	def value
		@value
	end

	def get_value(db, attribute)
		begin
			return db.execute(@value) if @type == 'query'
			return attribute[value]
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

	def validate(db, attribute)
		begin
			temp_file = Tempfile.new('tmp')
			temp_cmd = @cmd
			@params.each do |p|
				temp_cmd = temp_cmd.sub("?", p.get_value(db, attribute))
			end
			result = system "#{temp_cmd} 1>>#{temp_file.path} 2>>#{temp_file.path}"
			return nil if result
			error = temp_file.read
			return error
		rescue Exception => e
			return e
		ensure
			temp_file.unlink if temp_file
		end	
	end

end

class BlankValidator
	def initialize(params)
		super(params)
	end

	def validate(db, attribute)
		begin
			@params.each do |p|
				return "Value is Blank" if p.get_value(db, attribute).blank?
			end
			return nil
		rescue Exception => e
			return e
		end	
	end
end

class TypeValidator
	def initialize(params, datatype)
		super(params)
		@datatype = datatype
	end

	def validate(db, attribute)
		begin
			@params.each do |p|
				value = p.get_value(db, attribute)
				return "Value not an integer" if @datatype == :integer and !integer(value)
				return "Value not a float" if @datatype == :float and !float(value)
				return "Value not a string" if value.blank?
			end
			return nil
		rescue Exception => e
			return e
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

class QueryValidator
	def initialize(params, query)
		super(params)
		@query = query
	end

	def validate(db, attribute)
		begin
			values = []
			params.each do |p|
				values.push(p.get_value(db, attribute))
			end
			result = db.execute(db, *values)
			if nil result and result[0]
			return result[1]
		rescue Exception => e
			return e
		end	
	end
end



