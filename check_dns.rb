require 'resolv'

require "net/https"
require "uri"
require 'open-uri' 


class DnsCheck
	attr_reader :host
	def initialize(host)
		@host = host
	end

	def a
		@a ||= Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::A)
	end

	def a?
		a.any?
	end

	def mx
		@mx ||= Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::MX)
	end

	def mx?
		mx.any?
	end

	def ns
		@ns ||= Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::NS)
	end

	def ns?
		ns.any?
	end

	def cname
    @cname ||= Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::CNAME)
  end

  def cname?
    cname.any?
  end

  def ip
    Resolv.getaddress(host)
  end

end

domains = %w[
  juliendesrosiers.ca juliendesrosiers.com
  opto.com optosys.ca tv.opto.com web.opto.com
]

def check_status(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  res = http.request(request)

  res.code
end

def check_redirect_location(uri)
  r = Net::HTTP.get_response(uri)
  r.header['location']
end

def check_domain(domain)
  uri = URI.parse("https://#{domain}/")
  record_type = :CNAME if DnsCheck.new(domain).cname?
  record_type = :A if DnsCheck.new(domain).a?
  record_ip = DnsCheck.new(domain).ip
  status_code = check_status(uri)
  redirect_to = if (300..399).include?(status_code.to_i)
                  check_redirect_location(uri)
                else
                  nil
                end

  puts "DOMAIN: #{domain},\tRECORD: #{record_type},\tIP: #{record_ip},\tSTATUS: #{status_code}#{redirect_to ? ",\tREDIRECTS: #{redirect_to}" : ''}"
end

def check(domain, is_subdomain = false)
  uri = URI.parse("https://#{domain}/")

  check_domain(domain)
  check_domain("www.#{domain}") unless is_subdomain
  puts "-------------------------------------------------"
end

domains.each do |domain|
  domain_parts = domain.split('.')
  if domain_parts.size > 2
    check(domain, true)
  else
    check(domain)
  end
end

