Emu.ModelCollection = Ember.ArrayProxy.extend
  init: ->
    @set("content", Ember.A([]))
    @createRecord = (hash) ->      
      primaryKey = Emu.Model.primaryKey(@get("type"))
      paramHash = 
        store: @get("store")
      paramHash[primaryKey] = hash?.id
      model = @get("type").create(paramHash)     
      model.setProperties(hash)            
      @pushObject(model)
    @addObserver "content.@each", =>
      @set("hasValue", true)
      @set("isDirty", true)
    
    @find = (predicate) -> 
      @get("content").find(predicate)