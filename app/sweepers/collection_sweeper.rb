class CollectionSweeper < ActionController::Caching::Sweeper
  observe Collection, CollectionItem, CollectionParticipant, CollectionProfile, Work
  
  def after_save(record)
    expire_collection_cache_for(record)
  end

  def after_destroy(record)
    expire_collection_cache_for(record)
  end
  
  private
  # return one or many collections associated with the changed record 
  # converted into an array
  def get_collections_from_record(record)
    if record.is_a?(Collection)
      # send collection, its parent, and any children 
      ([record, record.parent] + record.children).compact
    elsif record.respond_to?(:collection) && !record.collection.nil?
      ([record.collection, record.collection.parent] + record.collection.children).compact
    elsif record.respond_to?(:collections)
      (record.collections + record.collections.collect(&:parent) + record.collections.collect(&:children).flatten).compact
    else
      []
    end
  end
      
  # Whenever these records are updated, we need to blank out the collections cache
  def expire_collection_cache_for(record)
    collections = get_collections_from_record(record)
    collections.each do |collection|
      
      # expire the collection blurb and dashboard and profile
      expire_fragment("collection-blurb-#{collection.id}")
      expire_fragment("collection-profile-#{collection.id}")
    end
  end

end