##########################################################################
# Copyright 2018 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################
require 'uri'

module CurlBuilder
  @generated_curls = ["#!/usr/bin/env bash"]

  def self.build(request)
    generated_curl = "curl #{basic_auth(request)} --url #{request.url} -X #{request.method} #{toCurlHeader(request.headers)} #{payload(request)}"
    @generated_curls << generated_curl
    generated_curl
  end

  def self.allUrls
    @generated_curls
  end

  def self.clearAllUrls
    @generated_curls = ["#!/usr/bin/env bash"]
  end

  private
  def self.payload request
    if ['PUT', 'PATCH', 'POST'].include?(request.method.upcase)
      "-d '#{URI.decode(request.payload.to_s)}'"
    end
  end

  def self.basic_auth request
    authorization = request.headers[:Authorization]
    unless authorization.nil?
      "-u #{Base64.decode64(authorization.gsub('Basic ', ''))}"
    end
  end

  def self.toCurlHeader herders
    nameMapping = {:content_type => 'Content-Type'}
    valueMappings = {'json' => 'application/json'}
    allHeaders = []
    unless herders.nil?
      herders.each {|name, value|
        unless name == :Authorization
          allHeaders << "-H '#{ nameMapping[name] || name}: #{valueMappings[value] || value}'"
        end
      }
    end
    allHeaders.join(' ')
  end
end