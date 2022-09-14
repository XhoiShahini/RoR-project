require 'net/http/post/multipart'

class PdfjsService
  def self.merge_xfdf(document, meeting_member)
    puts "merging"
    body = {}
    body[:license] = ENV['PDFJS_EXPRESS_LICENSE']

    body[:file] = "#{ENV['MERGE_DOMAIN']}/meetings/#{document.meeting.id}/documents/#{document.id}/merge"

    body[:xfdf] = meeting_member.xfdf
    body[:headers] = []

    url = URI.parse(ENV['PDFJS_EXPRESS_URL'])
    req = Net::HTTP::Post::Multipart.new(url.path, body)
    res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      result = JSON.parse(http.request(req).body)
      Rails.logger.info(result)
      download_merged_pdf(result['url'], result['key'], document, meeting_member)
    end
  end

  def self.download_merged_pdf(file_url, key, document, meeting_member)
    url = URI(file_url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true if url.scheme == 'https'

    request = Net::HTTP::Get.new(url)
    request["Authorization"] =  key
    response = https.request(request)
    meeting_member.update_column(:xfdf_merged, true)
    document.update_column(:next_merge, nil)
    document.file.attach(io: StringIO.new(response.body) , filename: "#{document.id}.pdf")
    # open(temp_url, "wb") do |file|
    #   file.write(response.body)
    # end
  end
end