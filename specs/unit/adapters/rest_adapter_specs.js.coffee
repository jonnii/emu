describe "Emu.RestAdapter", ->	
	Person = Emu.Model.extend()
	serializer = Ember.Object.create
		serializeTypeName: ->
		deserializeCollection: ->
		deserializeModel: ->
		serializeModel: ->
	Serializer = 
		create: -> serializer
	describe "When creating", ->
		beforeEach ->
			spyOn(Emu.Serializer, "create")
			@adapter = Emu.RestAdapter.create()
		it "should create the default serializer", ->
			expect(Emu.Serializer.create).toHaveBeenCalled()
	describe "When finding all", ->
		beforeEach ->
			spyOn($, "ajax")			
			models = Emu.ModelCollection.create()
			store = Ember.Object.create()
			spyOn(serializer, "serializeTypeName").andReturn("person")
			@adapter = Emu.RestAdapter.create
				namespace: "api"
				serializer: Serializer
			@adapter.findAll(Person, store, models)
		it "should make a GET request to the endpoint for the entity", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
			expect($.ajax.mostRecentCall.args[0].type).toEqual("GET")
	describe "When finding all with no namespace set", ->
		beforeEach ->
			spyOn($, "ajax")			
			models = Emu.ModelCollection.create()
			store = Ember.Object.create()
			spyOn(serializer, "serializeTypeName").andReturn("person")
			@adapter = Emu.RestAdapter.create
				serializer: Serializer
			@adapter.findAll(Person, store, models)
		it "should make a GET request to the endpoint for the entity", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("person")
	describe "When find all completes successfully", ->
		beforeEach ->
			@jsonData = [
				firstName: "Larry"
				lastName: "Laffer"
			]
			spyOn($, "ajax")
			@models = Emu.ModelCollection.create()
			@store = Ember.Object.create
				didFindAll: ->
			spyOn(serializer, "serializeTypeName").andReturn("person")
			spyOn(serializer, "deserializeCollection")
			spyOn(@store, "didFindAll")
			@adapter = Emu.RestAdapter.create
				namespace: "api"
				serializer: Serializer
			@adapter.findAll(Person, @store, @models)
			$.ajax.mostRecentCall.args[0].success(@jsonData)
		it "should deserialize the result", ->
			expect(serializer.deserializeCollection).toHaveBeenCalledWith(@models, @jsonData)
		it "should notify the store", ->
			expect(@store.didFindAll).toHaveBeenCalledWith(@models)
	describe "When finding by ID", ->
		beforeEach ->
			spyOn($, "ajax")			
			model = Person.create()
			store = Ember.Object.create()
			spyOn(serializer, "serializeTypeName").andReturn("person")
			@adapter = Emu.RestAdapter.create
				namespace: "api"
				serializer: Serializer
			@adapter.findById(Person, store, model, 5)
		it "should make a GET request to the endpoint for the entity", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person/5")
			expect($.ajax.mostRecentCall.args[0].type).toEqual("GET")
	describe "When finding by ID completes successfully", ->
		beforeEach ->
			@jsonData = 
				firstName: "Larry"
				lastName: "Laffer"		
			spyOn($, "ajax")			
			@model = Person.create()
			@store = Ember.Object.create(didFindById: ->)
			spyOn(serializer, "serializeTypeName").andReturn("person")
			spyOn(serializer, "deserializeModel")
			spyOn(@store, "didFindById")
			@adapter = Emu.RestAdapter.create
				namespace: "api"
				serializer: Serializer
			@adapter.findById(Person, @store, @model, 5)
			$.ajax.mostRecentCall.args[0].success(@jsonData)
		it "should deserialize the model", ->
			expect(serializer.deserializeModel).toHaveBeenCalledWith(@model, @jsonData)
		it "should notify the store", ->
			expect(@store.didFindById).toHaveBeenCalledWith(@model)
	describe "When finding all for a collection that has a parent", ->
		beforeEach ->
			spyOn($, "ajax")			
			ParentPerson = Emu.Model.extend()
			parent = ParentPerson.create(id: 5)
			models = Emu.ModelCollection.create(parent: parent, type: Person)
			store = Ember.Object.create()
			spyOn(serializer, "serializeTypeName").andCallFake (type) ->
				if type == ParentPerson 
					return "parentperson"
				if type == Person
					return "person"
			@adapter = Emu.RestAdapter.create
				namespace: "api"
				serializer: Serializer
			@adapter.findAll(Person, store, models)
		it "should make a GET request to the endpoint for the entity", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/parentperson/5/person")
			expect($.ajax.mostRecentCall.args[0].type).toEqual("GET")
	describe "When inserting a model", ->
		beforeEach ->
			@store = Ember.Object.create()
			spyOn($, "ajax")
			@jsonData = {name: "Henry"}
			@model = Person.create()
			@adapter = Emu.RestAdapter.create
				namespace: "api"
				serializer: Serializer
			spyOn(serializer, "serializeModel").andReturn(@jsonData)
			spyOn(serializer, "serializeTypeName").andReturn("person")
			@adapter.insert(@store, @model)
		it "should deserialize the model", ->
			expect(serializer.serializeModel).toHaveBeenCalledWith(@model)
		it "should send a POST request", ->
			expect($.ajax.mostRecentCall.args[0].type).toEqual("POST")
		it "should send the deserialized model in the request", ->
			expect($.ajax.mostRecentCall.args[0].data).toEqual(@jsonData)
		it "should serialize the type name", ->
			expect(serializer.serializeTypeName).toHaveBeenCalledWith(@model.constructor)
		it "should send the request to the correct URL for the model", ->
			expect($.ajax.mostRecentCall.args[0].url).toEqual("api/person")
	describe "When inserting a model and the request completes", ->
		beforeEach ->		
			@store = 
				didSave: ->
			spyOn(@store, "didSave")
			spyOn($, "ajax")
			@jsonData = {name: "Henry"}
			@model = Person.create()
			@adapter = Emu.RestAdapter.create
				namespace: "api"
				serializer: Serializer
			spyOn(serializer, "serializeModel").andReturn(@jsonData)
			spyOn(serializer, "serializeTypeName").andReturn("person")
			spyOn(serializer, "deserializeModel")
			@adapter.insert(@store, @model)
			@response =
				id: 5
				name: "Henry"
			$.ajax.mostRecentCall.args[0].success(@response)				
		it "should deserialize the model", ->
			expect(serializer.deserializeModel).toHaveBeenCalledWith(@model, @response)
		it "should notify the store", ->
			expect(@store.didSave).toHaveBeenCalledWith(@model)