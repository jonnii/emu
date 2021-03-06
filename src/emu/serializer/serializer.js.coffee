Emu.Serializer = Ember.Object.extend
  serializeKey: (key) -> key[0].toLowerCase() + key.slice(1);

  deserializeKey: (key) -> key

  serializeTypeName: (type) ->
    parts = type.toString().split(".")
    @serializeKey(parts[parts.length - 1])
  
  serializeModel: (model) ->
    jsonData = {}
    jsonData[model.primaryKey()] = model.primaryKeyValue()
    model.constructor.eachEmuField (property, meta) =>    
      @_serializeProperty(model, jsonData, property, meta)      
    jsonData
  
  deserializeModel: (model, jsonData, addative) ->
    primaryKeyValue = jsonData[model.primaryKey()]
    model.primaryKeyValue(primaryKeyValue) if primaryKeyValue
    model.constructor.eachEmuField (property, meta) =>
      serializedProperty = @serializeKey(property)
      @_deserializeProperty(model, property, jsonData[serializedProperty], meta, addative)  
    model
  
  deserializeCollection: (collection, jsonData, addative) ->
    existingItems = collection.toArray()
    collection.clear()
    if addative
      ids = jsonData.map (item) -> item[collection.get("type").primaryKey()]
      missingItems = existingItems.filter (item) -> 
        not ids.contains(item.primaryKeyValue())
      collection.pushObjects(missingItems)
    
    jsonData.forEach (item) =>      
      existingModel = existingItems.find (x) -> x.primaryKeyValue() == item[x.primaryKey()]
      model = if existingModel then collection.pushObject(existingModel) else collection.createRecord()
      @deserializeModel(model, item, addative)     
  
  serializeQueryHash: (queryHash) ->
    queryString = "?"
    for key, value of queryHash
      queryString += @serializeKey(key) + "=" + value + "&"
    queryString.slice(0, queryString.length - 1)
  
  _deserializeProperty: (model, property, value, meta, addative) ->   
    if meta.options.collection      
      if value then @deserializeCollection(Emu.Model.getAttr(model, property), value, addative) 
    else if meta.isModel()
      if value
        modelProperty = Emu.Model.getAttr(model, property)
        @deserializeModel(modelProperty, value) 
    else
      attributeSerializer = Emu.AttributeSerializers[meta.type()]
      value = attributeSerializer.deserialize(value)
      model.set(property, value) if value
  
  _serializeProperty: (model, jsonData, property, meta) ->    
    value = Emu.Model.getAttr(model, property)
    serializedKey = @serializeKey(property)
    if meta.options.collection
        jsonData[serializedKey] = if value?.get("hasValue") then value.map (item) => @serializeModel(item)
    else if meta.isModel()
      jsonData[serializedKey] = @serializeModel(value) if value.get("hasValue")
    else
      if value
        attributeSerializer = Emu.AttributeSerializers[meta.type()]
        jsonData[serializedKey] = attributeSerializer.serialize(value)
