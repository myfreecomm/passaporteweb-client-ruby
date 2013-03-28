# encoding: utf-8
require 'ostruct'
module PassaporteWeb

  class Helpers

    # Converts pagination information from a Link header in a HTTP response to a Hash
    #
    # Example:
    #   link_header = "<http://sandbox.app.passaporteweb.com.br/organizations/api/accounts/?page=3&limit=3>; rel=next, <http://sandbox.app.passaporteweb.com.br/organizations/api/accounts/?page=1&limit=3>; rel=prev, <http://sandbox.app.passaporteweb.com.br/organizations/api/accounts/?page=5&limit=3>; rel=last, <http://sandbox.app.passaporteweb.com.br/organizations/api/accounts/?page=1&limit=3>; rel=first"
    #   PassaporteWeb::Helpers.meta_links_from_header(link_header)
    #   => {limit: 3, next_page: 3, prev_page: 1, first_page: 1, last_page: 5}
    def self.meta_links_from_header(link_header)
      hash = {limit: nil, next_page: nil, prev_page: nil, first_page: nil, last_page: nil}
      links = link_header.split(',').map(&:strip)

      if link_header.match(/limit\=([0-9]+)/)
        hash[:limit] = Integer($1)
      end

      links.each do |link|
        if link.match(/page\=([0-9]+).*rel\=([a-z]+)/)
          case $2
          when 'next'
            hash[:next_page] = Integer($1)
          when 'prev'
            hash[:prev_page] = Integer($1)
          when 'first'
            hash[:first_page] = Integer($1)
          when 'last'
            hash[:last_page] = Integer($1)
          end
        end
      end

      hash
    end

    # Converts a Hash recursevely to a OpenStruct object.
    #
    # Example:
    #   hash = {a: 1, b: {c: 3, d: 4, e: {f: 6, g: 7}}}
    #   os = PassaporteWeb::Helpers.convert_to_ostruct_recursive(hash)
    #   os.a # => 1
    #   os.b # => {c: 3, d: 4, e: {f: 6, g: 7}}
    #   os.b.c # => 3
    #   os.b.d # => 4
    #   os.b.e # => {f: 6, g: 7}
    #   os.b.e.f # => 6
    #   os.b.e.g # => 7
    def self.convert_to_ostruct_recursive(obj, options={})
      result = obj
      if result.is_a? Hash
        result = result.dup
        result.each do |key, val|
          result[key] = convert_to_ostruct_recursive(val, options) unless (!options[:exclude].nil? && options[:exclude].include?(key))
        end
        result = OpenStruct.new result
      elsif result.is_a? Array
        result = result.map { |r| convert_to_ostruct_recursive(r, options) }
      end
      return result
    end

  end

end
