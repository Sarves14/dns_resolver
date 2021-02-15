if(ARGV.empty?)
    puts "empty argument"
    exit
end
domain = ARGV.first

dns_raw = File.readlines("zone.txt")
$typeA = {}
$typeC = {}

def parse_dns(dns_raw)
  dns_raw.each do |raw_record|
    record = raw_record.split(",")

    if record[0] == "A"
      $typeA[record[1].strip.to_sym] = record[2].strip
    
    elsif record[0] == "CNAME"
      $typeC[record[1].strip.to_sym] = record[2].strip
    
    else
      puts "Wrong record type"
    end
  end

  dns_record = {}
  dns_record[:typeA] = $typeA
  dns_record[:typeC] = $typeC
  return dns_record
end


def resolve(dns_records, output, new_domain)
  if dns_records[:typeA][new_domain.to_sym]
    output.append(dns_records[:typeA][new_domain.to_sym])
    return output

  elsif dns_records[:typeC][new_domain.to_sym]
    output.append(dns_records[:typeC][new_domain.to_sym])
    resolve(dns_records, output, dns_records[:typeC][new_domain.to_sym])
  else
    puts "#{new_domain} has no IPv4 address in the zone file"
    output.append("End")
    return output
  end
end



dns_records = parse_dns(dns_raw)
puts $typeA
puts $typeC
output = [domain]
output = resolve(dns_records, output, domain)

puts output.join(" => ")


