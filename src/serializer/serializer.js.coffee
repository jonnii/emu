Emu.Serializer = Ember.Object.extend
  serializeKey: (key) -> key[0].toLowerCase() + key.slice(1);

  deserializeKey: (key) -> key

  serializeTypeName: (type) ->
    parts = type.toString().split(".")
    @serializeKey(parts[parts.length - 1])
  
  serializeModel: (model) ->
    jsonData = 
      id: model.get("id")
    model.constructor.eachEmuField (property, meta) =>    
      @_serializeProperty(model, jsonData, property, meta)      
    jsonData
  
  deserializeModel: (model, jsonData) ->
    model.set("id", jsonData.id) if jsonData.id
    model.constructor.eachEmuField (property, meta) =>
      serializedProperty = @serializeKey(property)
      @_deserializeProperty(model, property, jsonData[serializedProperty], meta)  
    model
  
  deserializeCollection: (collection, jsonData) ->
    jsonData.forEach (item) =>
      model = collection.createRecord()
      @deserializeModel(model, item)      
  
  serializeQueryHash: (queryHash) ->
    queryString = "?"
    for key, value of queryHash
      queryString += @serializeKey(key) + "=" + value + "&"
    queryString.slice(0, queryString.length - 1)
  
  _deserializeProperty: (model, property, value, meta) ->   
    if meta.options.collection
      if value
        collection = Emu.ModelCollection.create
          type: meta.type()       
          parent: model
        @deserializeCollection(collection, value)
        model.set(property, collection)
    else if meta.isModel()
      if value
        modelProperty = meta.type().create()
        @deserializeModel(modelProperty, value) 
        model.set(property, modelProperty)
    else
      attributeSerializer = Emu.AttributeSerializers[meta.type()]
      value = attributeSerializer.deserialize(value)
      model.set(property, value) if value
  
  _serializeProperty: (model, jsonData, property, meta) ->    
    serializedKey = @serializeKey(property)
    if meta.options.collection
      if collection = model.getValueOf(property)
        jsonData[serializedKey] = collection.map (item) => @serializeModel(item)
    else if meta.isModel()
      propertyValue = model.getValueOf(property)
      jsonData[serializedKey] = @serializeModel(propertyValue) if propertyValue
    else
      attributeSerializer = Emu.AttributeSerializers[meta.type()]
      jsonData[serializedKey] = attributeSerializer.serialize(model.getValueOf(property))
