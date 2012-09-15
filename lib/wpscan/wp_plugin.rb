#--
# WPScan - WordPress Security Scanner
# Copyright (C) 2012
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

require "#{WPSCAN_LIB_DIR}/vulnerable"

class WpPlugin < Vulnerable
  include WpItem

  def initialize(options = {})
    @base_url       = options[:base_url]
    @path           = options[:path]
    @wp_content_dir = options[:wp_content_dir]
    @name           = options[:name] || extract_name_from_url(get_url)
    @vulns_xml      = options[:vulns_xml] || DATA_DIR + '/plugin_vulns.xml'
    @vulns_xpath    = "//plugin[@name='#@name']/vulnerability"
    @version        = nil

    raise("base_url not set") unless @base_url
    raise("path not set") unless @path
    raise("wp_content_dir not set") unless @wp_content_dir
    raise("name not set") unless @name
    raise("vulns_xml not set") unless @vulns_xml
  end

  # Discover any error_log files created by WordPress
  # These are created by the WordPress error_log() function
  # They are normally found in the /plugins/ directory,
  # however can also be found in their specific plugin dir.
  # http://www.exploit-db.com/ghdb/3714/
  def error_log?
    response_body = Browser.instance.get(error_log_url(), :headers => { "range" => "bytes=0-700"}).body
    response_body[%r{PHP Fatal error}i] ? true : false
  end

  def error_log_url
    get_url.merge("error_log").to_s
  end

end
