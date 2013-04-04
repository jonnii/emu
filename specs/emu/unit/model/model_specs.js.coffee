describe "Emu.Model", ->  
  Person = Emu.Model.extend
    name: Emu.field("string")
    orders: Emu.field("App.Order", {collection:true})
  it "should have a flag to indicate the type is an Emu model", ->
    expect(Person.isEmuModel).toBeTruthy()

  describe "createRecord", ->
    beforeEach ->
        Ember.set(Emu, "defaultStore", undefined)
        @store = Emu.Store.create()
        spyOn(@store, "createRecord")
        @model = Person.createRecord()
      it "should proxy the call to the default store", ->
        expect(@store.createRecord).toHaveBeenCalledWith(Person)

  describe "find", ->
    beforeEach ->
      Ember.set(Emu, "defaultStore", undefined)
      @store = Emu.Store.create()
      spyOn(@store, "find")
      @model = Person.find(5)
    it "should proxy the call to the default store", ->
      expect(@store.find).toHaveBeenCalledWith(Person, 5)

  describe "save", ->
    
    describe "no store specified", ->
      beforeEach ->
        Ember.set(Emu, "defaultStore", undefined)
        @store = Emu.Store.create()
        spyOn(@store, "save")
        @model = Person.createRecord()
        @model.save()
      it "should proxy the call to the store", ->
        expect(@store.save).toHaveBeenCalledWith(@model)
    
    describe "passing a store", ->
      beforeEach ->
        Ember.set(Emu, "defaultStore", undefined)
        @defaultStore = Emu.Store.create()
        @newStore = Emu.Store.create()
        spyOn(@defaultStore, "save")
        spyOn(@newStore, "save")
        @model = Person.create(store: @newStore)
        @model.save()
      it "should proxy the call to the specified store", ->
        expect(@newStore.save).toHaveBeenCalledWith(@model)
      it "should not proxy the call to the default store", ->
        expect(@defaultStore.save).not.toHaveBeenCalled()

  describe "When modifying a property on a model", ->
    beforeEach ->
      @model = Person.create(isDirty:false)
      @model.set("name", "Harold")
    it "should be in a dirty state", ->
      expect(@model.get("isDirty")).toBeTruthy()
      
  describe "When modifying a collection property on a model", ->
    beforeEach ->
      @model = Person.create
        isDirty:false             
      @model.get("orders").pushObject(App.Order.create())
    it "should be in a dirty state", ->
      expect(@model.get("isDirty")).toBeTruthy()  

  describe "getAttr", ->    
    
    describe "collection", ->      
      
      describe "not set", ->
        
        describe "get once", ->
          beforeEach ->
            spyOn(Emu.ModelCollection, "create").andCallThrough()
            @model = Person.create()           
            @result = Emu.Model.getAttr(@model, "orders")
          it "should create an empty collection", ->
            expect(Emu.ModelCollection.create).toHaveBeenCalled()
          it "should have the model as the parent", ->
            expect(@result.get("parent")).toBe(@model)
          it "should be of the type specified in the meta data for the field", ->
            expect(@result.get("type")).toBe(App.Order)

        describe "get twice", ->
          beforeEach ->
            spyOn(Emu.ModelCollection, "create").andCallThrough()
            @model = Person.create()           
            @result1 = Emu.Model.getAttr(@model, "orders")
            @result2 = Emu.Model.getAttr(@model, "orders")
          it "should return the same collection", ->
            expect(@result1).toBe(@result2)
  