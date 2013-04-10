Emu.AttributeSerializers = 
  
  string:    
    serialize: (value) -> 
      if Ember.isEmpty(value) then null else value
    
    deserialize: (value) -> 
      if Ember.isEmpty(value) then null else value
  
  array:    
    serialize: (value) -> 
      if Em.typeOf(value) is 'array' then value else null
    
    deserialize: (value) -> 
      switch Em.typeOf(value)
        when "array"  then value
        when "string" then value.split(',').map((item)-> jQuery.trim(item))
        else null

  boolean:
    serialize: (value) -> 
      if Ember.isEmpty(value) then null else value
    
    deserialize: (value) -> 
      if Ember.isEmpty(value) then null else value

  datetime:
    serialize: (value) ->
      return null if Ember.isEmpty(value)
      # not sure if toISOString is in every browser... might need
      # to format differently
      return value.toISOString()