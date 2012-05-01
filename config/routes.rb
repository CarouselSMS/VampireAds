ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'

  map.namespace 'admin' do |admin|
    admin.resources :screens
  end
  
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  map.smartlist 'messages/smartlist',
    :controller => "messages",
    :action     => "smartlist"

  map.connect 'messages/service_layer_callback/:screen',
    :controller => "messages",
    :action     => "service_layer_callback"

  map.connect 'messages/service_layer_callback',
    :controller => "messages",
    :action     => "service_layer_callback"
  
  map.connect 'messages/send_to_flash/:screen',
    :controller => "messages",
    :action     => "send_to_flash"
  
  # Not used?
  map.connect 'messages/:phone_num/:body', 
  	:controller => "messages", 
  	:action 		=> "receive",
  	:body	  		=> /.+/

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
