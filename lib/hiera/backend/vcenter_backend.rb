require 'RbVviews'

class Hiera
  module Backend
    class Vcenter_backend
      def initialize  
        Hiera.debug("Hiera VMware vCenter backend initialized")
      end

      def lookup(key, scope, order_override, resolution_type)
        Hiera.debug("Looking up \"#{key}\" in vCenter")
        Hiera.debug("Scope of \"#{scope}\"")
	Hiera.debug("Order_override of \"#{order_override}\"")
	Hiera.debug("Resolution_type: #{resolution_type}")


        #Establishc onnection to VC
        config = Config[:vcenter]
	vc_view = RbVviews.new(config[:server],config[:username],config[:password])
        vc_view.connect
	vim = vc_view.instance_variable_get(:@vim)

        #Lookup custom field names and keys
        propSet = [ { :type => 'CustomFieldsManager', :pathSet => ['field'], :all => false  } ]
        filterSpec = RbVmomi::VIM.PropertyFilterSpec(
          :objectSet => [ :obj => vim.serviceContent.customFieldsManager ],
          :propSet => propSet
        )

        result = vim.propertyCollector.RetrieveProperties(:specSet => [filterSpec])
        $hashCustomField = Hash.new
        result[0].obj.field.each {|cf| $hashCustomField[cf.key] = cf.name }


        # Search list of domains specified in the hierarchy section in hiera.yaml
        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for vCenter vminstanceuuid #{source}")
	  @source = source
          vm = vc_view.get_view('VirtualMachine','config.instanceUuid',source)
	
      	  #doesn't work with array lookup yet
	  results = []

          #Create hash of key,value for custom values
          $hashCustomValue = Hash.new
          vm.select {|vm| vm.obj['config.instanceUuid'] == @source.chomp}.each {|vm| 
            vm.obj.customValue.each {|cv| 
              $hashCustomValue[cv.key] = cv.value
            }
          }


          #Create array of actual field names and values
          $arrOut = []
          $hashCustomValue.each {|key,value|
            $classes = value if $hashCustomField[key] == "puppet.classes"
            $arrOut << "#{$hashCustomField[key]}=#{value}" 
          }

          Hiera.debug("answer: #{$classes}")
          classes = $classes.to_s.split(',')
          classes = [] unless $classes
          answer = classes
          Hiera.debug("returning: #{answer}")
          vc_view.close

	  return answer
        end
      end
    end
  end
end

