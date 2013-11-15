# Copyright (c) 2013 Algol Labs, LLC. <dev@algollabs.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

module Sinatra::API
  # API for defining parameters an endpoint requires or accepts, their types,
  # and optional validators.
  #
  module Resources
    private

    # Attempt to locate a resource based on an ID supplied in a request parameter.
    #
    # If the param map contains a resource id (ie, :folder_id),
    # we attempt to locate and expose it to the route.
    #
    # A 404 is raised if:
    #   1. the scope is missing (@space for folder, @space or @folder for page)
    #   2. the resource couldn't be identified in its scope (@space or @folder)
    #
    # If the resources were located, they're accessible using @folder or @page.
    #
    # The route can be halted using the :requires => [] condition when it expects
    # a resource.
    #
    # @example using :requires to reject a request with an invalid @page
    #   get '/folders/:folder_id/pages/:page_id', :requires => [ :page ] do
    #     @page.show    # page is good
    #     @folder.show  # so is its folder
    #   end
    #
    def api_locate_resource(r, container = nil)
      resource_id = params[r + '_id'].to_i
      rklass      = r.camelize

      collection = case
      when container.nil?;  eval "#{ResourcePrefix}#{rklass}"
      else;                 container.send("#{r.to_plural}")
      end

      puts "locating resource #{r} with id #{resource_id} from #{collection} [#{container}]"

      resource = collection.get(resource_id)

      if !resource
        m = "No such resource: #{rklass}##{resource_id}"
        if container
          m << " in #{container.class.name.to_s}##{container.id}"
        end

        halt 404, m
      end

      if respond_to?(:can?)
        unless can? :access, resource
          halt 403, "You do not have access to this #{rklass} resource."
        end
      end

      instance_variable_set('@'+r, resource)

      Sinatra::API.trigger :resource_located, resource, r

      resource
    end
  end
end