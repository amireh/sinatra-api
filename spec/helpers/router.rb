module Router
  class << self
    def puts(*args)
      super(*args) if $VERBOSE
    end

    # Locates routes defined for any verb containing the provided token.
    #
    # @param [String] token the token the route should contain
    # @return [Array<Hash, Fixnum>] a map of all the verb routes, and the count of located routes
    def routes_for(token)
      all_routes = {}
      count  = 0
      Sinatra::Application.routes.each do |verb_routes|
        verb, routes = verb_routes[0], verb_routes[1]
        all_routes[verb] ||= []
        routes.each_with_index do |route, i|
          route_regex = route.first.source
          if route_regex.to_s.include?(token)
            all_routes[verb] << route
            count += 1

            puts "Route located: #{verb} -> #{route_regex.to_s}"
          end
        end
        all_routes[verb].uniq!
      end
      [ all_routes, count ]
    end

    def purge(token)
      routes, nr_routes = *routes_for(token)

      # puts "cleaning up #{nr_routes} routes"

      routes.each_pair do |verb, vroutes|
        vroutes.each do |r| delete_route(verb, r) end
      end

      yield(nr_routes) if block_given?

      nr_routes
    end

    protected

    def delete_route(verb, r)
      verb_routes = Sinatra::Application.routes.select { |v| v == verb }.first

      unless verb_routes
        raise "Couldn't find routes for verb #{verb}, that's impossible"
      end

      unless verb_routes[1].delete(r)
        raise "Route '#{r}' not found for verb #{verb}"
      end
    end

  end
end