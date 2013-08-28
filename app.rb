require 'sinatra'
require 'json'
require 'pp'

module StubServer
  class App < Sinatra::Base
    configure do
      set :show_exceptions, false
    end

    error do
      'Oops something went wrong: ' + env['sinatra.error'].message
    end

    before do
      #cache for 600s = 10 min
      cache_control :public, :must_revalidate, :max_age => 600
    end

    get '*/:folder_name/:file_name' do
      content_type :json
      puts request.path_info
      puts "* #{params[:folder_name]} * #{params[:file_name]} *"
      filename = "#{params[:folder_name]}/#{params[:file_name]}"
      filename += "?#{request.query_string}" unless request.query_string.length==0
      filename += '.json'
      hash = parse_json_file_into_hash filename

      hash.to_json
    end

    def try_to_find_file_with_any_combination_of_query_params(query_string)
      filename = ''
      query_string_hash = Rack::Utils.parse_nested_query(query_string)
      all_key_permutations = query_string_hash.keys.permutation.to_a
      all_key_permutations.each do |key_combination|
        new_query_string_hash_combination = Hash.new()
        key_combination.each do |key|
          new_query_string_hash_combination[key] = query_string_hash[key]
        end
        filename = Rack::Utils.build_query(new_query_string_hash_combination)
        if File.file?("StubServer/search/#{filename}.json")
          break
        end
      end
      filename
    end

    def parse_json_file_into_hash(filename)
      full_file_path = "#{filename}"
      if (!File.file?(full_file_path))
        puts "Could not find: #{full_file_path}"
        raise Sinatra::NotFound
      end
      data = File.read(full_file_path)
      begin
        JSON.parse(data)
      rescue
        raise "Could not parse JSON file '#{full_file_path}' "
      end
    end

    def make_relative_query_url_absolute(array)
      if (!array['query_url'].nil? && !array['query_url'].strip.empty?)
        array['query_url'] = "http://#{request.host_with_port}#{array['query_url']}"
      end
    end

    def make_relative_url_url_absolute(array)
      if (!array['url'].nil? && !array['url'].strip.empty? && !isAlreadyAbsoluteUrl?(array))
        array['url'] = "http://#{request.host_with_port}#{array['url']}"
      end
      if (!array['page'].nil? && !array['page']['next_url'].nil? && !array['page']['next_url'].strip.empty?)
        array['page']['next_url'] = "http://#{request.host_with_port}#{array['page']['next_url']}"
      end
    end

    def isAlreadyAbsoluteUrl?(array)
      array['url'].start_with?('http://') || array['url'].start_with?('https://')
    end
  end
end

